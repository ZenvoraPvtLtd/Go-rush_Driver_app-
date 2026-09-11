import 'package:flutter/material.dart';
import '../../core/theme.dart';

class OtpVerificationLivenessScreen extends StatefulWidget {
  final VoidCallback? onVerifySuccess;
  final VoidCallback? onBackTap;

  const OtpVerificationLivenessScreen({
    super.key,
    this.onVerifySuccess,
    this.onBackTap,
  });

  @override
  State<OtpVerificationLivenessScreen> createState() => _OtpVerificationLivenessScreenState();
}

class _OtpVerificationLivenessScreenState extends State<OtpVerificationLivenessScreen> {
  final List<String> _otpDigits = ['4', '8', '9', '2', '0', '1'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              const Text(
                'Verify Your Number',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter the 6-digit verification code sent to\n+91 98765 43210',
                style: TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 36),

              // 6 Square OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 48,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index < 4 ? QuickServeColors.primaryOrange : QuickServeColors.borderLight,
                        width: index < 4 ? 1.5 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _otpDigits[index],
                        style: const TextStyle(
                          color: QuickServeColors.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Resend Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive code? ",
                    style: TextStyle(color: QuickServeColors.textSecondary, fontSize: 13),
                  ),
                  const Text(
                    'Resend in 00:45',
                    style: TextStyle(
                      color: QuickServeColors.primaryOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Orange Verify CTA Button
              ElevatedButton(
                onPressed: widget.onVerifySuccess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Verify & Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
