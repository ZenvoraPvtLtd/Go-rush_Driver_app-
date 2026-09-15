import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_toast.dart';

class HelpCenterSupportTicketsScreen extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onRaiseTicketTap;
  final Function(int)? onBottomNavTap;

  const HelpCenterSupportTicketsScreen({
    super.key,
    this.onBackTap,
    this.onRaiseTicketTap,
    this.onBottomNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Support Hub',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input (Phone 17)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search help topics, fares, payouts...',
                    hintStyle: TextStyle(color: QuickServeColors.textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: QuickServeColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5 Support Option Cards (Phone 17)
              _buildSupportCard(
                icon: Icons.help_outline_rounded,
                iconColor: QuickServeColors.primaryBlue,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Help Center & FAQs',
                subtitle: 'Find answers to common questions about GoRush trips & earnings',
                onTap: () {
                  AppToast.info(context, 'Opening Help Center articles...');
                },
              ),
              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.chat_rounded,
                iconColor: QuickServeColors.statusGreen,
                iconBg: const Color(0xFFE8F8EE),
                title: 'Live Chat Support',
                subtitle: 'Chat directly with GoRush 24/7 driver support team',
                onTap: () {
                  AppToast.info(context, 'Connecting to GoRush live chat agent...');
                },
              ),
              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.phone_in_talk_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFFF3E8FF),
                title: 'Call Driver Helpline',
                subtitle: 'Direct phone helpline: +91 98765 43210 (Toll Free)',
                onTap: () {
                  AppToast.info(context, 'Dialing GoRush Helpline +91 98765 43210...');
                },
              ),
              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.report_problem_outlined,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Report an Issue',
                subtitle: 'Report a fare dispute, toll query, or passenger issue',
                onTap: onRaiseTicketTap ?? () {
                  AppToast.info(context, 'Ticket created: Case #GR-9822');
                },
              ),
              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.health_and_safety_outlined,
                iconColor: QuickServeColors.statusRed,
                iconBg: const Color(0xFFFEF2F2),
                title: 'Safety Guidelines & SOS',
                subtitle: 'Emergency protocols, road assistance & insurance coverage',
                onTap: () {
                  AppToast.info(context, 'Opening Driver Safety protocols...');
                },
              ),

              const SizedBox(height: 20),

              // Active Ticket Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Recent Support Ticket',
                          style: TextStyle(
                            color: QuickServeColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Case #GR-9822',
                          style: TextStyle(
                            color: QuickServeColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toll reimbursement query for Sector 62 expressway',
                      style: TextStyle(color: QuickServeColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: QuickServeColors.statusGreenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Resolved • Credited to Wallet',
                        style: TextStyle(color: QuickServeColors.statusGreen, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: QuickServeColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: QuickServeColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: QuickServeColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
