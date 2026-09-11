import 'package:flutter/material.dart';
import '../../core/theme.dart';

class UploadDocumentsScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBackTap;

  const UploadDocumentsScreen({
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
          'Upload Documents',
          style: TextStyle(color: QuickServeColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Required Partner Documents',
                style: TextStyle(color: QuickServeColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Please ensure images are clear, unblurred, and show valid expiry dates.',
                style: TextStyle(color: QuickServeColors.textSecondary, fontSize: 13),
              ),

              const SizedBox(height: 20),

              _buildDocCard(
                title: 'Commercial Driving License',
                subtitle: 'DL-142011001234 • Valid till 2031',
                isUploaded: true,
              ),
              const SizedBox(height: 12),
              _buildDocCard(
                title: 'Vehicle RC (Registration)',
                subtitle: 'DL 01 AB 1234 • Honda City Sedan',
                isUploaded: true,
              ),
              const SizedBox(height: 12),
              _buildDocCard(
                title: 'Commercial Insurance Policy',
                subtitle: 'Policy #BA-9921004 • Valid till Oct 2026',
                isUploaded: true,
              ),
              const SizedBox(height: 12),
              _buildDocCard(
                title: 'Driver Aadhaar & PAN Card',
                subtitle: 'Aadhaar Verified • Biometric Complete',
                isUploaded: true,
              ),

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
                    Text('Next: Bank Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildDocCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUploaded ? const Color(0xFFE8F8EE) : const Color(0xFFFFECE6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUploaded ? Icons.verified : Icons.upload_file,
              color: isUploaded ? QuickServeColors.statusGreen : QuickServeColors.primaryOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: QuickServeColors.textDark, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: QuickServeColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isUploaded ? const Color(0xFFE8F8EE) : QuickServeColors.primaryOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isUploaded ? 'Verified' : 'Upload',
              style: TextStyle(
                color: isUploaded ? QuickServeColors.statusGreen : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
