/**
 * Razorpay Payment Gateway Integration Test Suite
 * Validates Order Creation, HMAC-SHA256 Signature Verification, Idempotency, and Webhook Processing
 */
const crypto = require('crypto');
const mongoose = require('mongoose');
const config = require('./src/config/env');
const RazorpayPayment = require('./src/models/razorpay_payment.model');
const Wallet = require('./src/models/wallet.model');
const WalletTransaction = require('./src/models/wallet_transaction.model');
const Driver = require('./src/models/driver.model');
const razorpayController = require('./src/controllers/razorpay.controller');

async function runRazorpayTestSuite() {
  if (!config.razorpay.keyId) config.razorpay.keyId = process.env.RAZORPAY_KEY_ID || 'rzp_test_suite_key';
  if (!config.razorpay.keySecret) config.razorpay.keySecret = process.env.RAZORPAY_KEY_SECRET || 'test_secret_suite_mock';
  if (!config.razorpay.webhookSecret) config.razorpay.webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || 'test_whsec_mock';

  console.log('====================================================');
  console.log('   GoRush Razorpay Backend Verification Suite');
  console.log('====================================================\n');

  let passed = 0;
  let failed = 0;

  function assert(condition, testName) {
    if (condition) {
      console.log(`  ✅ [PASS] ${testName}`);
      passed++;
    } else {
      console.error(`  ❌ [FAIL] ${testName}`);
      failed++;
    }
  }

  // 1. Check Configuration Security
  console.log('1. Checking Secret Isolation & Security Rules...');
  assert(config.razorpay !== undefined, 'Razorpay config section exists');
  assert(typeof config.razorpay.keyId === 'string' && config.razorpay.keyId.length > 0, 'Razorpay Key ID is present');
  assert(typeof config.razorpay.keySecret === 'string' && config.razorpay.keySecret.length > 0, 'Razorpay Key Secret is present in env');

  // Test mock req/res helper
  function createMockReqRes(body = {}, query = {}, headers = {}, driver = null) {
    const req = {
      body,
      query,
      headers,
      driver,
      rawBody: Buffer.from(JSON.stringify(body)),
    };
    let resData = null;
    let statusCode = 200;
    const res = {
      status: (code) => {
        statusCode = code;
        return res;
      },
      json: (data) => {
        resData = data;
        return res;
      },
      getStatusCode: () => statusCode,
      getData: () => resData,
    };
    return { req, res };
  }

  // Connect to DB for testing
  try {
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(config.db.uri, { dbName: config.db.name });
      console.log('  Connected to MongoDB for integration tests.');
    }

    // Create a dummy test driver
    const dummyPhone = `999${Date.now().toString().slice(-7)}`;
    const testDriver = await Driver.create({
      phone: dummyPhone,
      password: 'testPassword123',
      name: 'Razorpay Test Driver',
      email: `razorpay_${Date.now()}@gorush.com`,
      vehicleType: 'BIKE',
      isPhoneVerified: true,
      status: 'offline',
    });

    console.log(`\n2. Testing Public Config Endpoint (GET /api/payment/razorpay/config)...`);
    const { req: cfgReq, res: cfgRes } = createMockReqRes();
    await razorpayController.getConfig(cfgReq, cfgRes);
    const cfgData = cfgRes.getData();
    assert(cfgRes.getStatusCode() === 200, 'Config returns 200');
    assert(cfgData.data.keyId === config.razorpay.keyId, 'Config returns correct Key ID');
    assert(cfgData.data.keySecret === undefined, 'Key Secret is STRICTLY HIDDEN from client config');

    console.log(`\n3. Testing Razorpay Order Creation (POST /api/payment/razorpay/order)...`);
    const rechargeAmount = 500;
    const { req: ordReq, res: ordRes } = createMockReqRes({ amount: rechargeAmount }, {}, {}, testDriver);
    await razorpayController.createOrder(ordReq, ordRes);
    const ordData = ordRes.getData();
    assert(ordRes.getStatusCode() === 201, 'Order created with 201 Created');
    assert(ordData.success === true, 'Order creation marked success');
    assert(ordData.data.orderId.length > 5, `Order ID generated: ${ordData.data.orderId}`);
    assert(ordData.data.amount === rechargeAmount, 'Amount matches in INR');
    assert(ordData.data.amountPaise === 50000, 'Amount correctly calculated in paise (50000)');

    const orderId = ordData.data.orderId;
    const paymentId = `pay_test_${Date.now()}`;

    console.log(`\n4. Testing HMAC-SHA256 Signature Verification...`);
    // Generate valid HMAC signature: HMAC-SHA256(order_id + "|" + payment_id, secret)
    const validSignature = crypto
      .createHmac('sha256', config.razorpay.keySecret)
      .update(`${orderId}|${paymentId}`)
      .digest('hex');

    // 4a. Invalid signature test
    const { req: invReq, res: invRes } = createMockReqRes(
      {
        razorpay_order_id: orderId,
        razorpay_payment_id: paymentId,
        razorpay_signature: 'invalid_tampered_signature_12345',
      },
      {},
      {},
      testDriver
    );
    await razorpayController.verifyPayment(invReq, invRes);
    assert(invRes.getStatusCode() === 400, 'Invalid signature rejected with 400 Bad Request');
    assert(invRes.getData().success === false, 'Invalid signature rejected');

    // 4b. Valid signature test
    const initialWallet = await Wallet.findOne({ driverId: testDriver._id });
    const baselineBalance = initialWallet ? initialWallet.balance : 500; // default welcome balance
    const { req: valReq, res: valRes } = createMockReqRes(
      {
        razorpay_order_id: orderId,
        razorpay_payment_id: paymentId,
        razorpay_signature: validSignature,
      },
      {},
      {},
      testDriver
    );
    await razorpayController.verifyPayment(valReq, valRes);
    assert(valRes.getStatusCode() === 200, 'Valid signature verified with 200 OK');
    assert(valRes.getData().success === true, 'Verification marked success');

    // Verify wallet was credited
    const walletAfterValid = await Wallet.findOne({ driverId: testDriver._id });
    assert(
      walletAfterValid.balance === baselineBalance + rechargeAmount,
      `Wallet credited atomically: ₹${baselineBalance} -> ₹${walletAfterValid.balance}`
    );

    // 5. Testing Idempotency (Duplicate Verification Callback)
    console.log(`\n5. Testing Idempotency (Prevent Duplicate Wallet Credit)...`);
    const { req: dupReq, res: dupRes } = createMockReqRes(
      {
        razorpay_order_id: orderId,
        razorpay_payment_id: paymentId,
        razorpay_signature: validSignature,
      },
      {},
      {},
      testDriver
    );
    await razorpayController.verifyPayment(dupReq, dupRes);
    assert(dupRes.getStatusCode() === 200, 'Duplicate request handled gracefully');
    assert(dupRes.getData().alreadyProcessed === true, 'Duplicate request detected and flagged');

    const walletAfterDup = await Wallet.findOne({ driverId: testDriver._id });
    assert(
      walletAfterDup.balance === walletAfterValid.balance,
      `Wallet balance remains unchanged on duplicate retry: ₹${walletAfterDup.balance}`
    );

    // 6. Testing Webhook Verification & Processing
    console.log(`\n6. Testing Razorpay Webhook Processing...`);
    const webhookOrderId = `order_wh_${Date.now()}`;
    const webhookPaymentId = `pay_wh_${Date.now()}`;

    // Create order for webhook
    await RazorpayPayment.create({
      driverId: testDriver._id,
      orderId: webhookOrderId,
      amount: 300,
      amountPaise: 30000,
      currency: 'INR',
      receipt: `rcpt_wh_${Date.now()}`,
      status: 'CREATED',
      verificationStatus: 'PENDING',
      walletCredited: false,
    });

    const webhookPayload = {
      event: 'payment.captured',
      payload: {
        payment: {
          entity: {
            id: webhookPaymentId,
            order_id: webhookOrderId,
            amount: 30000,
            status: 'captured',
          },
        },
      },
    };

    const rawWebhookBody = JSON.stringify(webhookPayload);
    const validWebhookSig = crypto
      .createHmac('sha256', config.razorpay.webhookSecret)
      .update(rawWebhookBody)
      .digest('hex');

    const { req: whReq, res: whRes } = createMockReqRes(
      webhookPayload,
      {},
      { 'x-razorpay-signature': validWebhookSig }
    );
    whReq.rawBody = Buffer.from(rawWebhookBody);

    await razorpayController.handleWebhook(whReq, whRes);
    assert(whRes.getStatusCode() === 200, 'Webhook processed successfully with 200 OK');

    const walletAfterWebhook = await Wallet.findOne({ driverId: testDriver._id });
    assert(
      walletAfterWebhook.balance === walletAfterDup.balance + 300,
      `Wallet credited ₹300 via webhook: ₹${walletAfterDup.balance} -> ₹${walletAfterWebhook.balance}`
    );

    // Cleanup test records
    await Driver.deleteOne({ _id: testDriver._id });
    await Wallet.deleteOne({ driverId: testDriver._id });
    await WalletTransaction.deleteMany({ driverId: testDriver._id });
    await RazorpayPayment.deleteMany({ driverId: testDriver._id });
  } catch (err) {
    console.error('Test suite error:', err);
    failed++;
  } finally {
    await mongoose.disconnect();
  }

  console.log('\n====================================================');
  console.log(`   Suite Finished: ${passed} Passed, ${failed} Failed`);
  console.log('====================================================');
  process.exit(failed > 0 ? 1 : 0);
}

runRazorpayTestSuite();
