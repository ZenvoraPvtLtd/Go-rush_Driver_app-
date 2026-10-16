const mongoose = require('mongoose');

/**
 * GoRush Razorpay Payment Ledger
 * Tracks all Razorpay checkout sessions, orders, verification states, and webhook events.
 */
const razorpayPaymentSchema = new mongoose.Schema(
  {
    driverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Driver',
      required: [true, 'Driver ID is required'],
      index: true,
    },
    orderId: {
      type: String,
      required: [true, 'Razorpay Order ID is required'],
      unique: true,
      trim: true,
      index: true,
    },
    paymentId: {
      type: String,
      trim: true,
      default: null,
      index: true,
    },
    signature: {
      type: String,
      trim: true,
      default: null,
    },
    amount: {
      type: Number,
      required: [true, 'Amount in INR is required'],
      min: [1, 'Amount must be at least ₹1'],
    },
    amountPaise: {
      type: Number,
      required: [true, 'Amount in paise is required'],
    },
    currency: {
      type: String,
      default: 'INR',
      trim: true,
    },
    receipt: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    status: {
      type: String,
      enum: ['CREATED', 'ATTEMPTED', 'PAID', 'FAILED', 'CANCELLED', 'REFUNDED'],
      default: 'CREATED',
      index: true,
    },
    verificationStatus: {
      type: String,
      enum: ['PENDING', 'VERIFIED', 'FAILED'],
      default: 'PENDING',
      index: true,
    },
    purpose: {
      type: String,
      enum: ['WALLET_RECHARGE', 'SUBSCRIPTION', 'JOINING_FEE', 'ORDER_PAYMENT', 'OTHER'],
      default: 'WALLET_RECHARGE',
    },
    walletCredited: {
      type: Boolean,
      default: false,
      index: true,
    },
    walletTransactionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'WalletTransaction',
      default: null,
    },
    failureReason: {
      type: String,
      default: null,
      trim: true,
    },
    driverSnapshot: {
      name: { type: String, default: null },
      phone: { type: String, default: null },
      email: { type: String, default: null },
    },
    verifiedAt: {
      type: Date,
      default: null,
    },
    notes: {
      type: Map,
      of: String,
      default: {},
    },
    webhookEvents: [
      {
        event: { type: String, required: true },
        receivedAt: { type: Date, default: Date.now },
        razorpayPaymentId: { type: String, default: null },
      },
    ],
  },
  {
    timestamps: true,
    collection: 'razorpay_payments',
  }
);

// Safe serialization for Flutter client & Admin audits
razorpayPaymentSchema.methods.toSafeObject = function () {
  return {
    _id: this._id,
    driverId: this.driverId,
    orderId: this.orderId,
    paymentId: this.paymentId,
    amount: this.amount,
    amountPaise: this.amountPaise,
    currency: this.currency,
    receipt: this.receipt,
    status: this.status,
    verificationStatus: this.verificationStatus,
    purpose: this.purpose,
    walletCredited: this.walletCredited,
    walletTransactionId: this.walletTransactionId,
    failureReason: this.failureReason,
    driverSnapshot: this.driverSnapshot,
    verifiedAt: this.verifiedAt,
    notes: this.notes,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt,
  };
};

const RazorpayPayment = mongoose.model(
  'RazorpayPayment',
  razorpayPaymentSchema,
  'razorpay_payments'
);

module.exports = RazorpayPayment;
