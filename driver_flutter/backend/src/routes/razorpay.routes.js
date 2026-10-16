const express = require('express');
const router = express.Router();
const razorpayController = require('../controllers/razorpay.controller');
const { protect, optionalProtect } = require('../middleware/auth.middleware');

// GET /api/payment/razorpay/config - Public/client configuration (Key ID, currency)
router.get('/config', razorpayController.getConfig);

// POST /api/payment/razorpay/order - Create Razorpay order
router.post('/order', protect, razorpayController.createOrder);

// POST /api/payment/razorpay/verify - Verify HMAC-SHA256 signature and credit wallet
router.post('/verify', protect, razorpayController.verifyPayment);

// GET /api/payment/razorpay/order/:orderId - Order status inquiry
router.get('/order/:orderId', optionalProtect, razorpayController.getOrderStatus);

// POST /api/payment/razorpay/webhook - Razorpay webhook endpoint
router.post('/webhook', razorpayController.handleWebhook);

// GET /api/payment/razorpay/transactions - Transaction history
router.get('/transactions', protect, razorpayController.getTransactions);

module.exports = router;
