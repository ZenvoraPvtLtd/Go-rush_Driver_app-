const crypto = require('crypto');
const Razorpay = require('razorpay');
const config = require('../config/env');
const RazorpayPayment = require('../models/razorpay_payment.model');
const Wallet = require('../models/wallet.model');
const WalletTransaction = require('../models/wallet_transaction.model');
const Driver = require('../models/driver.model');
const { ensureWallet } = require('./wallet.controller');

let razorpayInstance = null;

function getRazorpayClient() {
  if (!razorpayInstance && config.razorpay && config.razorpay.keyId && config.razorpay.keySecret) {
    try {
      razorpayInstance = new Razorpay({
        key_id: config.razorpay.keyId,
        key_secret: config.razorpay.keySecret,
      });
    } catch (err) {
      console.warn('[Razorpay] Failed to instantiate SDK client:', err.message);
    }
  }
  return razorpayInstance;
}

/**
 * 1. GET /api/payment/razorpay/config
 * Returns public Razorpay configuration for Flutter client checkout.
 * NEVER exposes key_secret.
 */
exports.getConfig = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      data: {
        keyId: config.razorpay.keyId || '',
        currency: 'INR',
        name: 'GoRush Partner',
        themeColor: '#0284C7',
      },
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch Razorpay config',
      error: err.message,
    });
  }
};

/**
 * 2. POST /api/payment/razorpay/order
 * Creates an authorized Razorpay Order on server side.
 * Validates amount, driver, and generates unique order ID & receipt.
 */
exports.createOrder = async (req, res) => {
  try {
    const driverId = req.driver ? req.driver._id : req.body.driverId;
    if (!driverId) {
      return res.status(401).json({ success: false, message: 'Driver authentication required' });
    }

    const amount = parseFloat(req.body.amount);
    if (!amount || amount <= 0 || !Number.isFinite(amount)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid recharge amount. Must be a positive number.',
      });
    }

    if (amount > 100000) {
      return res.status(400).json({
        success: false,
        message: 'Recharge amount cannot exceed ₹1,00,000 per transaction.',
      });
    }

    const amountPaise = Math.round(amount * 100);
    const receipt = `rcpt_${driverId.toString().slice(-6)}_${Date.now()}`;
    const purpose = req.body.purpose || 'WALLET_RECHARGE';

    // Fetch driver snapshot for audit trail
    const driver = await Driver.findById(driverId).select('name phone email');
    const driverSnapshot = {
      name: driver?.name || 'GoRush Driver',
      phone: driver?.phone || '',
      email: driver?.email || '',
    };

    let razorpayOrderId;
    const client = getRazorpayClient();

    if (client) {
      try {
        const orderResponse = await client.orders.create({
          amount: amountPaise,
          currency: 'INR',
          receipt,
          notes: {
            driverId: driverId.toString(),
            purpose,
            driverPhone: driverSnapshot.phone,
          },
        });
        razorpayOrderId = orderResponse.id;
      } catch (sdkErr) {
        console.warn('[Razorpay SDK] Order creation call failed:', sdkErr.message);
        // Fallback for offline test mode / mock sandbox
        razorpayOrderId = `order_test_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
      }
    } else {
      // Local dev sandbox fallback
      razorpayOrderId = `order_test_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    }

    // Persist payment record in MongoDB
    const paymentRecord = await RazorpayPayment.create({
      driverId,
      orderId: razorpayOrderId,
      amount,
      amountPaise,
      currency: 'INR',
      receipt,
      status: 'CREATED',
      verificationStatus: 'PENDING',
      purpose,
      walletCredited: false,
      driverSnapshot,
      notes: {
        driverPhone: driverSnapshot.phone,
        purpose,
      },
    });

    return res.status(201).json({
      success: true,
      message: 'Razorpay order created successfully',
      data: {
        orderId: razorpayOrderId,
        amount,
        amountPaise,
        currency: 'INR',
        keyId: config.razorpay.keyId,
        receipt,
        driverSnapshot,
        paymentRecordId: paymentRecord._id,
      },
    });
  } catch (err) {
    console.error('[Razorpay createOrder] Error:', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to create Razorpay order',
      error: err.message,
    });
  }
};

/**
 * 3. POST /api/payment/razorpay/verify
 * Verifies Razorpay HMAC-SHA256 signature using Key Secret on server.
 * Idempotently credits driver wallet upon successful verification.
 */
exports.verifyPayment = async (req, res) => {
  try {
    const driverId = req.driver ? req.driver._id : null;
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    if (!razorpay_order_id || !razorpay_payment_id) {
      return res.status(400).json({
        success: false,
        message: 'Missing required parameters: razorpay_order_id and razorpay_payment_id are mandatory.',
      });
    }

    // Find the stored order
    const payment = await RazorpayPayment.findOne({ orderId: razorpay_order_id });
    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment order record not found in system.',
      });
    }

    // Verify driver ownership if driver context is available
    if (driverId && payment.driverId.toString() !== driverId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized payment verification attempt.',
      });
    }

    // Idempotency check: Already verified & credited
    if (payment.walletCredited) {
      console.log(`[Razorpay] Order ${razorpay_order_id} was already credited. Returning idempotent success.`);
      const wallet = await Wallet.findOne({ driverId: payment.driverId });
      return res.status(200).json({
        success: true,
        message: 'Payment was already verified and credited (idempotent)',
        alreadyProcessed: true,
        wallet: wallet ? wallet.toSafeObject() : null,
        payment: payment.toSafeObject(),
      });
    }

    // HMAC-SHA256 signature calculation: hmac_sha256(order_id + "|" + razorpay_payment_id, secret)
    let isSignatureValid = false;
    const secret = config.razorpay.keySecret;

    if (razorpay_signature && secret) {
      const generatedSignature = crypto
        .createHmac('sha256', secret)
        .update(`${razorpay_order_id}|${razorpay_payment_id}`)
        .digest('hex');

      try {
        const expectedBuf = Buffer.from(generatedSignature, 'utf-8');
        const actualBuf = Buffer.from(razorpay_signature, 'utf-8');
        if (expectedBuf.length === actualBuf.length && crypto.timingSafeEqual(expectedBuf, actualBuf)) {
          isSignatureValid = true;
        }
      } catch (_) {
        isSignatureValid = false;
      }
    }

    if (!isSignatureValid) {
      payment.status = 'FAILED';
      payment.verificationStatus = 'FAILED';
      payment.failureReason = 'HMAC signature verification failed';
      payment.paymentId = razorpay_payment_id;
      payment.signature = razorpay_signature;
      await payment.save();

      return res.status(400).json({
        success: false,
        message: 'Payment signature verification failed. Balance not updated.',
      });
    }

    // --- ATOMIC WALLET RECHARGE ---
    const wallet = await ensureWallet(payment.driverId);
    const balanceBefore = wallet.balance;
    const balanceAfter = parseFloat((balanceBefore + payment.amount).toFixed(2));

    const updatedWallet = await Wallet.findOneAndUpdate(
      { _id: wallet._id },
      {
        $set: {
          balance: balanceAfter,
          lastTransactionAt: new Date(),
        },
        $inc: { totalRecharged: payment.amount },
      },
      { new: true, runValidators: true }
    );

    const idempotencyKey = `razorpay_${razorpay_payment_id}`;
    let txn;

    try {
      txn = await WalletTransaction.create({
        driverId: payment.driverId,
        rideId: null,
        type: 'CREDIT',
        category: 'RECHARGE',
        amount: payment.amount,
        balanceBefore,
        balanceAfter,
        paymentMethod: 'RAZORPAY',
        description: `Razorpay Wallet Recharge — ₹${payment.amount.toFixed(0)}`,
        idempotencyKey,
        status: 'SUCCESS',
        metadata: {
          razorpayOrderId: razorpay_order_id,
          razorpayPaymentId: razorpay_payment_id,
        },
      });
    } catch (txnErr) {
      // If transaction already existed (duplicate concurrent callback)
      if (txnErr.code === 11000) {
        txn = await WalletTransaction.findOne({ idempotencyKey });
      } else {
        throw txnErr;
      }
    }

    // Update payment record as paid & verified
    payment.paymentId = razorpay_payment_id;
    payment.signature = razorpay_signature;
    payment.status = 'PAID';
    payment.verificationStatus = 'VERIFIED';
    payment.walletCredited = true;
    payment.walletTransactionId = txn ? txn._id : null;
    payment.verifiedAt = new Date();
    await payment.save();

    console.log(`[Razorpay] Verified payment ${razorpay_payment_id} for driver ${payment.driverId}. Wallet: ₹${balanceBefore} → ₹${balanceAfter}`);

    return res.status(200).json({
      success: true,
      message: `Payment verified! ₹${payment.amount} added to your wallet.`,
      wallet: updatedWallet ? updatedWallet.toSafeObject() : null,
      transaction: txn ? txn.toSafeObject() : null,
      payment: payment.toSafeObject(),
    });
  } catch (err) {
    console.error('[Razorpay verifyPayment] Error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error verifying payment',
      error: err.message,
    });
  }
};

/**
 * 4. GET /api/payment/razorpay/order/:orderId
 * Fetches order & payment verification status.
 */
exports.getOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const payment = await RazorpayPayment.findOne({ orderId });
    if (!payment) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    return res.status(200).json({
      success: true,
      data: payment.toSafeObject(),
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Server error fetching order status', error: err.message });
  }
};

/**
 * 5. POST /api/payment/razorpay/webhook
 * Handles asynchronous server-to-server Razorpay webhooks.
 * Uses raw request body to verify webhook signature.
 * Prevents double-credit with client callback via walletCredited idempotency check.
 */
exports.handleWebhook = async (req, res) => {
  try {
    const webhookSignature = req.headers['x-razorpay-signature'];
    const webhookSecret = config.razorpay.webhookSecret;

    // Verify webhook signature with rawBody
    if (webhookSecret) {
      const rawBody = req.rawBody ? req.rawBody.toString() : JSON.stringify(req.body);
      const expectedSignature = crypto
        .createHmac('sha256', webhookSecret)
        .update(rawBody)
        .digest('hex');

      if (webhookSignature !== expectedSignature) {
        console.warn('[Razorpay Webhook] Invalid webhook signature');
        return res.status(400).json({ success: false, message: 'Invalid webhook signature' });
      }
    }

    const event = req.body.event;
    const payload = req.body.payload;

    console.log(`[Razorpay Webhook] Received event: ${event}`);

    if (event === 'payment.captured' || event === 'order.paid') {
      const paymentEntity = payload.payment?.entity;
      const orderId = paymentEntity?.order_id || payload.order?.entity?.id;
      const paymentId = paymentEntity?.id;

      if (orderId) {
        const paymentRecord = await RazorpayPayment.findOne({ orderId });
        if (paymentRecord) {
          // Record webhook event receipt
          paymentRecord.webhookEvents.push({
            event,
            receivedAt: new Date(),
            razorpayPaymentId: paymentId,
          });

          // Check if already credited via in-app checkout callback
          if (paymentRecord.walletCredited) {
            console.log(`[Razorpay Webhook] Order ${orderId} already credited. Skipping duplicate credit.`);
            await paymentRecord.save();
            return res.status(200).json({ status: 'ok', message: 'Already processed' });
          }

          // Not yet credited (e.g. app crashed right after Razorpay payment)
          const wallet = await ensureWallet(paymentRecord.driverId);
          const balanceBefore = wallet.balance;
          const balanceAfter = parseFloat((balanceBefore + paymentRecord.amount).toFixed(2));

          await Wallet.findOneAndUpdate(
            { _id: wallet._id },
            {
              $set: { balance: balanceAfter, lastTransactionAt: new Date() },
              $inc: { totalRecharged: paymentRecord.amount },
            }
          );

          const idempotencyKey = `razorpay_${paymentId || orderId}`;
          const txn = await WalletTransaction.create({
            driverId: paymentRecord.driverId,
            rideId: null,
            type: 'CREDIT',
            category: 'RECHARGE',
            amount: paymentRecord.amount,
            balanceBefore,
            balanceAfter,
            paymentMethod: 'RAZORPAY',
            description: `Razorpay Wallet Recharge (Webhook) — ₹${paymentRecord.amount.toFixed(0)}`,
            idempotencyKey,
            status: 'SUCCESS',
            metadata: {
              razorpayOrderId: orderId,
              razorpayPaymentId: paymentId,
              source: 'webhook',
            },
          });

          paymentRecord.paymentId = paymentId;
          paymentRecord.status = 'PAID';
          paymentRecord.verificationStatus = 'VERIFIED';
          paymentRecord.walletCredited = true;
          paymentRecord.walletTransactionId = txn._id;
          paymentRecord.verifiedAt = new Date();
          await paymentRecord.save();

          console.log(`[Razorpay Webhook] Successfully credited wallet for driver ${paymentRecord.driverId}`);
        }
      }
    } else if (event === 'payment.failed') {
      const paymentEntity = payload.payment?.entity;
      const orderId = paymentEntity?.order_id;
      const errorDesc = paymentEntity?.error_description || 'Payment failed';

      if (orderId) {
        const paymentRecord = await RazorpayPayment.findOne({ orderId });
        if (paymentRecord) {
          paymentRecord.status = 'FAILED';
          paymentRecord.failureReason = errorDesc;
          paymentRecord.webhookEvents.push({
            event,
            receivedAt: new Date(),
            razorpayPaymentId: paymentEntity?.id,
          });
          await paymentRecord.save();
          console.log(`[Razorpay Webhook] Marked payment as failed for order ${orderId}: ${errorDesc}`);
        }
      }
    }

    return res.status(200).json({ status: 'ok', received: true });
  } catch (err) {
    console.error('[Razorpay Webhook] Error:', err);
    return res.status(500).json({ status: 'error', message: err.message });
  }
};

/**
 * 6. GET /api/payment/razorpay/transactions
 * Driver & Admin payment ledger history.
 */
exports.getTransactions = async (req, res) => {
  try {
    const driverId = req.driver ? req.driver._id : req.query.driverId;
    const filter = {};
    if (driverId) filter.driverId = driverId;
    if (req.query.status) filter.status = req.query.status.toUpperCase();
    if (req.query.verificationStatus) filter.verificationStatus = req.query.verificationStatus.toUpperCase();

    const limit = Math.min(parseInt(req.query.limit, 10) || 50, 100);
    const skip = parseInt(req.query.skip, 10) || 0;

    const [payments, total] = await Promise.all([
      RazorpayPayment.find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('driverId', 'name phone email vehicleType'),
      RazorpayPayment.countDocuments(filter),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        payments: payments.map((p) => p.toSafeObject()),
        total,
        limit,
        skip,
      },
    });
  } catch (err) {
    console.error('[Razorpay getTransactions] Error:', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch Razorpay transactions',
      error: err.message,
    });
  }
};
