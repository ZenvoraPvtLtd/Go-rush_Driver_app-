import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/safe_avatar.dart';

class DriverProfileSetupScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBackTap;

  const DriverProfileSetupScreen({
    super.key,
    this.onNext,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Driver Profile',
          style: TextStyle(color: QuickServeColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar with Change Photo
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: QuickServeColors.primaryOrange, width: 2.5),
                      ),
                      child: const SafeAvatar(
                        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                        radius: 42,
                        fallbackText: 'RS',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: QuickServeColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Change Photo',
                  style: TextStyle(
                    color: QuickServeColors.primaryOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildField('Full Name', 'Rohit Sharma'),
              const SizedBox(height: 16),
              _buildField('Email Address', 'rohit.sharma@quickserve.com'),
              const SizedBox(height: 16),
              _buildField('Date of Birth', '12-05-1995', suffixIcon: Icons.calendar_today),
              const SizedBox(height: 16),
              _buildField('City / Operational Hub', 'Noida & Delhi NCR'),
              const SizedBox(height: 16),
              _buildField('Permanent Address', 'Sector 62, Noida, Uttar Pradesh - 201309'),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next: Upload Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, {IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: QuickServeColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: QuickServeColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: QuickServeColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              if (suffixIcon != null)
                Icon(suffixIcon, color: QuickServeColors.textSecondary, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
