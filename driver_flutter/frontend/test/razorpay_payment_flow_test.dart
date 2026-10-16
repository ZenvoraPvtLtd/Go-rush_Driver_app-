import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gorush_driver/services/api_config.dart';
import 'package:gorush_driver/services/wallet_service.dart';
import 'package:gorush_driver/services/razorpay_payment_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('razorpay_flutter'), (MethodCall call) async {
      return null;
    });
  });

  group('Razorpay Integration Tests', () {
    test('ApiConfig has Razorpay endpoints defined', () {
      expect(ApiConfig.razorpayConfigEndpoint, '/api/payment/razorpay/config');
      expect(ApiConfig.razorpayOrderEndpoint, '/api/payment/razorpay/order');
      expect(ApiConfig.razorpayVerifyEndpoint, '/api/payment/razorpay/verify');
      expect(ApiConfig.razorpayTransactionsEndpoint, '/api/payment/razorpay/transactions');
    });

    test('RazorpayPaymentService singleton initializes and disposes cleanly', () {
      final service = RazorpayPaymentService.instance;
      expect(service, isNotNull);

      // Verify initialization
      service.initialize();

      // Verify safe disposal
      service.dispose();
      expect(service.activeOrderId, isNull);
      expect(service.activeAmount, isNull);
    });

    test('RazorpayCheckoutResult correctly maps success, cancellation and failure', () {
      const successResult = RazorpayCheckoutResult(
        status: RazorpayPaymentStatus.success,
        message: 'Payment verified successfully!',
        orderId: 'order_test_123',
        paymentId: 'pay_test_456',
        signature: 'sig_test_789',
      );
      expect(successResult.isSuccess, isTrue);
      expect(successResult.isCancelled, isFalse);
      expect(successResult.isFailed, isFalse);
      expect(successResult.orderId, 'order_test_123');

      const cancelledResult = RazorpayCheckoutResult(
        status: RazorpayPaymentStatus.cancelled,
        message: 'Payment cancelled.',
      );
      expect(cancelledResult.isCancelled, isTrue);
      expect(cancelledResult.isSuccess, isFalse);

      const failedResult = RazorpayCheckoutResult(
        status: RazorpayPaymentStatus.failed,
        message: 'Payment failed.',
      );
      expect(failedResult.isFailed, isTrue);
      expect(failedResult.isSuccess, isFalse);
    });

    test('WalletService updates wallet state after verified recharge', () {
      final walletService = WalletService.instance;
      const initialWallet = WalletInfo(
        balance: 500.0,
        minimumRequiredBalance: 100.0,
        currency: 'INR',
        isBlocked: false,
        isSufficient: true,
        totalRecharged: 500.0,
        totalCompanyChargesDeducted: 0.0,
      );

      walletService.updateWallet(initialWallet);
      expect(walletService.wallet?.balance, 500.0);

      final updatedWallet = initialWallet.copyWith(
        balance: 1000.0,
        totalRecharged: 1000.0,
      );
      walletService.updateWallet(updatedWallet);
      expect(walletService.wallet?.balance, 1000.0);
      expect(walletService.wallet?.totalRecharged, 1000.0);
    });
  });
}
