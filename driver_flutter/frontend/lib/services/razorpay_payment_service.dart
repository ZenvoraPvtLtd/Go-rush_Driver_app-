import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'token_storage_service.dart';
import 'wallet_service.dart';

/// Status of Razorpay checkout attempt
enum RazorpayPaymentStatus {
  success,
  cancelled,
  failed,
  externalWallet,
}

/// Result object encapsulating Razorpay checkout details
class RazorpayCheckoutResult {
  final RazorpayPaymentStatus status;
  final String message;
  final String? orderId;
  final String? paymentId;
  final String? signature;
  final String? externalWalletName;
  final int? errorCode;
  final dynamic extra;

  const RazorpayCheckoutResult({
    required this.status,
    required this.message,
    this.orderId,
    this.paymentId,
    this.signature,
    this.externalWalletName,
    this.errorCode,
    this.extra,
  });

  bool get isSuccess => status == RazorpayPaymentStatus.success;
  bool get isCancelled => status == RazorpayPaymentStatus.cancelled;
  bool get isFailed => status == RazorpayPaymentStatus.failed;
}

/// Production-grade Razorpay Payment Service for GoRush Driver App
/// Manages Razorpay checkout lifecycle, prevents duplicate listeners,
/// and delegates order creation and HMAC signature verification to the backend.
class RazorpayPaymentService {
  static final RazorpayPaymentService instance = RazorpayPaymentService._internal();
  factory RazorpayPaymentService() => instance;
  RazorpayPaymentService._internal();

  Razorpay? _razorpay;
  bool _isInitialized = false;

  Completer<RazorpayCheckoutResult>? _currentCheckoutCompleter;
  String? _activeOrderId;
  double? _activeAmount;

  String? get activeOrderId => _activeOrderId;
  double? get activeAmount => _activeAmount;

  /// Fallback test key ID if backend config is unavailable
  static const String _defaultTestKeyId = 'rzp_test_5148492040182';

  /// Initialize Razorpay instance and register event listeners safely
  void initialize() {
    if (_isInitialized && _razorpay != null) return;

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _isInitialized = true;
    debugPrint('[RazorpayPaymentService] Initialized checkout listeners');
  }

  /// Cleanly detach listeners and clear resources on dispose
  void dispose() {
    try {
      _razorpay?.clear();
      _razorpay = null;
      _isInitialized = false;
      _currentCheckoutCompleter = null;
      _activeOrderId = null;
      _activeAmount = null;
      debugPrint('[RazorpayPaymentService] Disposed checkout listeners');
    } catch (e) {
      debugPrint('[RazorpayPaymentService] Dispose error: $e');
    }
  }

  /// Initiates a secure Razorpay checkout flow for Driver Wallet Recharge
  Future<RazorpayCheckoutResult> checkoutWalletRecharge({
    required double amount,
    BuildContext? context,
  }) async {
    if (amount <= 0) {
      return const RazorpayCheckoutResult(
        status: RazorpayPaymentStatus.failed,
        message: 'Invalid recharge amount. Must be greater than 0.',
      );
    }

    // Ensure listeners are registered
    initialize();

    // Prevent concurrent checkout operations
    if (_currentCheckoutCompleter != null && !_currentCheckoutCompleter!.isCompleted) {
      _currentCheckoutCompleter!.complete(
        const RazorpayCheckoutResult(
          status: RazorpayPaymentStatus.cancelled,
          message: 'Previous checkout session was cancelled.',
        ),
      );
    }

    _currentCheckoutCompleter = Completer<RazorpayCheckoutResult>();
    _activeAmount = amount;

    try {
      // 1. Ask backend to create a unique Razorpay Order
      final orderData = await WalletService.instance.createRazorpayOrder(
        amount,
        purpose: 'WALLET_RECHARGE',
      );

      final orderId = orderData?['orderId'] as String?;
      final keyId = orderData?['keyId'] as String? ??
          await WalletService.instance.fetchRazorpayKeyId() ??
          _defaultTestKeyId;

      if (orderId == null || orderId.isEmpty) {
        _currentCheckoutCompleter = null;
        return const RazorpayCheckoutResult(
          status: RazorpayPaymentStatus.failed,
          message: 'Could not generate payment order from server. Please try again.',
        );
      }

      _activeOrderId = orderId;

      // 2. Fetch driver pre-fill information
      final profile = TokenStorageService.instance.driverProfile;
      final driverPhone = profile?['phone']?.toString() ?? '';
      final driverEmail = profile?['email']?.toString() ?? 'driver@gorush.com';
      final driverName = profile?['name']?.toString() ?? 'GoRush Captain';

      final amountPaise = (amount * 100).round();

      // 3. Configure checkout options
      final options = {
        'key': keyId,
        'amount': amountPaise,
        'name': 'GoRush Partner',
        'description': 'Driver Wallet Top-Up (₹${amount.toStringAsFixed(0)})',
        'order_id': orderId,
        'timeout': 180, // 3 minutes timeout
        'prefill': {
          'contact': driverPhone,
          'email': driverEmail,
          'name': driverName,
        },
        'theme': {
          'color': '#0284C7', // GoRush blue
        },
        'retry': {
          'enabled': true,
          'max_count': 3,
        },
        'send_sms_hash': true,
      };

      debugPrint('[RazorpayPaymentService] Launching Razorpay for order $orderId with key: $keyId');
      _razorpay!.open(options);

      return await _currentCheckoutCompleter!.future;
    } catch (e) {
      debugPrint('[RazorpayPaymentService] Launch error: $e');
      _currentCheckoutCompleter = null;
      return RazorpayCheckoutResult(
        status: RazorpayPaymentStatus.failed,
        message: 'Could not open payment sheet: ${e.toString()}',
      );
    }
  }

  /// Handles Razorpay EVENT_PAYMENT_SUCCESS
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('[RazorpayPaymentService] Success callback: payId=${response.paymentId}, orderId=${response.orderId}');

    final orderId = response.orderId ?? _activeOrderId ?? '';
    final paymentId = response.paymentId ?? '';
    final signature = response.signature ?? '';

    // Verify signature with backend before crediting balance
    final verifyResult = await WalletService.instance.verifyAndApplyRazorpayPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    );

    final checkoutResult = RazorpayCheckoutResult(
      status: verifyResult.success ? RazorpayPaymentStatus.success : RazorpayPaymentStatus.failed,
      message: verifyResult.message,
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
      extra: verifyResult.wallet,
    );

    if (_currentCheckoutCompleter != null && !_currentCheckoutCompleter!.isCompleted) {
      _currentCheckoutCompleter!.complete(checkoutResult);
    }
  }

  /// Handles Razorpay EVENT_PAYMENT_ERROR
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('[RazorpayPaymentService] Error callback: code=${response.code}, message=${response.message}');

    final isCancelled = response.code == Razorpay.PAYMENT_CANCELLED;
    final friendlyMessage = isCancelled
        ? 'Payment cancelled. No money was deducted.'
        : (response.message != null && response.message!.isNotEmpty
            ? response.message!
            : 'Payment failed. Please retry or choose another payment method.');

    final checkoutResult = RazorpayCheckoutResult(
      status: isCancelled ? RazorpayPaymentStatus.cancelled : RazorpayPaymentStatus.failed,
      message: friendlyMessage,
      orderId: _activeOrderId,
      errorCode: response.code,
    );

    if (_currentCheckoutCompleter != null && !_currentCheckoutCompleter!.isCompleted) {
      _currentCheckoutCompleter!.complete(checkoutResult);
    }
  }

  /// Handles Razorpay EVENT_EXTERNAL_WALLET
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('[RazorpayPaymentService] External wallet selected: ${response.walletName}');

    final checkoutResult = RazorpayCheckoutResult(
      status: RazorpayPaymentStatus.externalWallet,
      message: 'Redirecting to external wallet: ${response.walletName}',
      orderId: _activeOrderId,
      externalWalletName: response.walletName,
    );

    if (_currentCheckoutCompleter != null && !_currentCheckoutCompleter!.isCompleted) {
      _currentCheckoutCompleter!.complete(checkoutResult);
    }
  }
}
