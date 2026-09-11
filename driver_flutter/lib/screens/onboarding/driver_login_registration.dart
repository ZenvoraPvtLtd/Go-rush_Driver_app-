import 'package:flutter/material.dart';
import '../../core/theme.dart';

class DriverLoginRegistrationScreen extends StatefulWidget {
  final VoidCallback? onGetOtp;
  final VoidCallback? onBackTap;

  const DriverLoginRegistrationScreen({
    super.key,
    this.onGetOtp,
    this.onBackTap,
  });

  @override
  State<DriverLoginRegistrationScreen> createState() => _DriverLoginRegistrationScreenState();
}

class _DriverLoginRegistrationScreenState extends State<DriverLoginRegistrationScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '98765 43210');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
                onPressed: widget.onBackTap,
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: QuickServeColors.primaryOrange,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: QuickServeColors.primaryOrange.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.speed, color: Colors.white, size: 36),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Welcome to QuickServe',
                  style: TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Center(
                child: Text(
                  'Enter your phone number to sign in or register as a partner driver.',
                  style: TextStyle(
                    color: QuickServeColors.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 36),

              const Text(
                'Phone Number',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // Phone Number Field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: QuickServeColors.borderLight, width: 1.2),
                ),
                child: Row(
                  children: [
                    const Text(
                      '+91',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 24, color: QuickServeColors.borderLight),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        style: const TextStyle(
                          color: QuickServeColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter 10-digit number',
                          hintStyle: TextStyle(color: QuickServeColors.textMuted, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Orange Continue Button
              ElevatedButton(
                onPressed: widget.onGetOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),

              // Or divider
              Row(
                children: [
                  const Expanded(child: Divider(color: QuickServeColors.borderLight)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'OR',
                      style: TextStyle(color: QuickServeColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(child: Divider(color: QuickServeColors.borderLight)),
                ],
              ),

              const SizedBox(height: 24),

              // Continue with Email Outlined
              OutlinedButton.icon(
                icon: const Icon(Icons.email_outlined, size: 18),
                label: const Text('Continue with Email'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: QuickServeColors.borderLight),
                  foregroundColor: QuickServeColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'By continuing, you agree to QuickServe Terms & Privacy Policy.',
                  style: TextStyle(
                    color: QuickServeColors.textMuted,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
