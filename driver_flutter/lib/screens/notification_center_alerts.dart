import 'package:flutter/material.dart';
import '../core/theme.dart';

class NotificationCenterAlertsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onSosTap;

  const NotificationCenterAlertsScreen({
    super.key,
    this.onBackTap,
    this.onSosTap,
  });

  @override
  State<NotificationCenterAlertsScreen> createState() => _NotificationCenterAlertsScreenState();
}

class _NotificationCenterAlertsScreenState extends State<NotificationCenterAlertsScreen> {
  int _selectedCategory = 0; // 0: All, 1: Payments, 2: Trips, 3: Alerts

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
          'Notifications',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: const Text(
              'Mark All Read',
              style: TextStyle(
                color: QuickServeColors.primaryOrange,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildChip('All (5)', 0),
                    const SizedBox(width: 8),
                    _buildChip('Payments', 1),
                    const SizedBox(width: 8),
                    _buildChip('Trips', 2),
                    const SizedBox(width: 8),
                    _buildChip('Alerts', 3),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: QuickServeColors.borderLight),

            // Notifications List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildNotificationItem(
                    icon: Icons.directions_car,
                    iconBg: const Color(0xFFFFECE6),
                    iconColor: QuickServeColors.primaryOrange,
                    title: 'New Ride Request Assigned',
                    message: 'Pickup at Sector 62, Noida ➔ Drop at Connaught Place, New Delhi.',
                    time: '10 min ago',
                    isUnread: true,
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    icon: Icons.check_circle,
                    iconBg: const Color(0xFFE8F8EE),
                    iconColor: QuickServeColors.statusGreen,
                    title: 'Payment Credited: ₹ 362',
                    message: 'Trip fare successfully credited to your wallet via UPI Google Pay.',
                    time: '1 hour ago',
                    isUnread: true,
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    icon: Icons.stars,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    title: 'Weekly Incentive Unlocked: ₹ 300',
                    message: 'Congratulations! You completed 12 peak-hour rides this week.',
                    time: '3 hours ago',
                    isUnread: false,
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    icon: Icons.warning_amber_rounded,
                    iconBg: const Color(0xFFFEF2F2),
                    iconColor: QuickServeColors.statusRed,
                    title: 'Document Expiry Warning',
                    message: 'Your Commercial Vehicle Insurance expires in 14 days. Tap to upload renewal.',
                    time: 'Yesterday',
                    isUnread: false,
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    icon: Icons.local_fire_department,
                    iconBg: const Color(0xFFFFECE6),
                    iconColor: QuickServeColors.primaryOrange,
                    title: 'Evening Rush Hour Surge 1.5x',
                    message: 'High demand expected in Cyber City & Noida Sector 62 between 5 PM and 9 PM.',
                    time: 'Yesterday',
                    isUnread: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, int index) {
    final isSelected = _selectedCategory == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? QuickServeColors.primaryOrange : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : QuickServeColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? QuickServeColors.primaryOrange.withOpacity(0.4) : QuickServeColors.borderLight,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: QuickServeColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: QuickServeColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: QuickServeColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: QuickServeColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
