import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/app_toast.dart';

class UploadDocumentsScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBackTap;

  const UploadDocumentsScreen({
    super.key,
    this.onNext,
    this.onBackTap,
  });

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  // Document states
  final List<Map<String, dynamic>> _documents = [
    {
      'title': 'Profile Photo',
      'subtitle': 'Passport size clear photo',
      'uploaded': true,
      'icon': Icons.account_box_outlined,
    },
    {
      'title': 'Driving License',
      'subtitle': 'DL-142011001234 • Front & Back',
      'uploaded': true,
      'icon': Icons.badge_outlined,
    },
    {
      'title': 'Vehicle RC',
      'subtitle': 'Registration Certificate DL 01 AB 1234',
      'uploaded': true,
      'icon': Icons.directions_car_outlined,
    },
    {
      'title': 'Vehicle Insurance',
      'subtitle': 'Commercial policy valid till Oct 2026',
      'uploaded': false,
      'icon': Icons.verified_user_outlined,
    },
    {
      'title': 'Police Verification',
      'subtitle': 'Character verification certificate',
      'uploaded': false,
      'icon': Icons.security_outlined,
    },
  ];

  void _handleSubmitDocuments() {
    setState(() {
      for (var doc in _documents) {
        doc['uploaded'] = true;
      }
    });
    AppToast.success(context, 'Documents submitted successfully!');
    if (widget.onNext != null) {
      widget.onNext!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Document upload',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Upload your documents for verification',
                      style: TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5 Document Cards (Phone 4)
                    ...List.generate(_documents.length, (idx) {
                      final doc = _documents[idx];
                      final isUploaded = doc['uploaded'] == true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isUploaded
                                ? QuickServeColors.statusGreen.withOpacity(0.3)
                                : QuickServeColors.borderLight,
                            width: 1.2,
                          ),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isUploaded
                                    ? QuickServeColors.statusGreenLight
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isUploaded ? Icons.verified : doc['icon'] as IconData,
                                color: isUploaded
                                    ? QuickServeColors.statusGreen
                                    : QuickServeColors.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['title'] as String,
                                    style: const TextStyle(
                                      color: QuickServeColors.textDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    doc['subtitle'] as String,
                                    style: const TextStyle(
                                      color: QuickServeColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _documents[idx]['uploaded'] = !_documents[idx]['uploaded'];
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isUploaded
                                      ? QuickServeColors.statusGreenLight
                                      : QuickServeColors.statusAmberLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isUploaded
                                        ? QuickServeColors.statusGreen
                                        : QuickServeColors.statusAmber,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUploaded ? Icons.check_circle : Icons.upload_file,
                                      size: 14,
                                      color: isUploaded
                                          ? QuickServeColors.statusGreen
                                          : QuickServeColors.statusAmber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isUploaded ? 'Uploaded' : 'Pending',
                                      style: TextStyle(
                                        color: isUploaded
                                            ? QuickServeColors.statusGreen
                                            : QuickServeColors.statusAmber,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmitDocuments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuickServeColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit Documents',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
