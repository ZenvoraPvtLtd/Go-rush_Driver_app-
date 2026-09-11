import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/safe_avatar.dart';
import '../widgets/app_bottom_nav.dart';

class DriverProfileVehicleSettingsScreen extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onVehicleTap;
  final VoidCallback? onDocumentsTap;
  final VoidCallback? onBankTap;
  final VoidCallback? onLogoutTap;
  final Function(int)? onBottomNavTap;

  const DriverProfileVehicleSettingsScreen({
    super.key,
    this.onBackTap,
    this.onVehicleTap,
    this.onDocumentsTap,
    this.onBankTap,
    this.onLogoutTap,
    this.onBottomNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile & Settings',
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
                    // Driver Profile Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: QuickServeColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: QuickServeColors.primaryOrange, width: 2),
                            ),
                            child: const SafeAvatar(
                              imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                              radius: 28,
                              fallbackText: 'RS',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rohit Sharma',
                                  style: TextStyle(
                                    color: QuickServeColors.textDark,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'rohit.sharma@quickserve.com',
                                  style: TextStyle(
                                    color: QuickServeColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '4.8',
                                      style: TextStyle(
                                        color: QuickServeColors.textDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F8EE),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Verified Driver',
                                        style: TextStyle(
                                          color: QuickServeColors.statusGreen,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Profile & Fleet Settings Section
                    _buildSettingsGroup([
                      _buildSettingItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update phone number & address',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.directions_car_outlined,
                        title: 'Vehicle Details',
                        subtitle: 'Honda City • DL 01 AB 1234',
                        onTap: onVehicleTap,
                      ),
                      _buildSettingItem(
                        icon: Icons.description_outlined,
                        title: 'Documents & Verification',
                        subtitle: 'Driving License, RC, Insurance',
                        badge: 'Verified',
                        badgeColor: QuickServeColors.statusGreen,
                        onTap: onDocumentsTap,
                      ),
                      _buildSettingItem(
                        icon: Icons.account_balance_outlined,
                        title: 'Bank Details & UPI',
                        subtitle: 'HDFC Bank • Instant Payouts',
                        onTap: onBankTap,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Preferences Section
                    _buildSettingsGroup([
                      _buildSettingItem(
                        icon: Icons.notifications_none_outlined,
                        title: 'Push Notifications',
                        subtitle: 'Ride alerts, surges & payments',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.language_outlined,
                        title: 'App Language',
                        subtitle: 'English (India)',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy & Security',
                        subtitle: 'Location permissions & biometric lock',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password / PIN',
                        subtitle: 'Update authentication credentials',
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Logout Button
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: QuickServeColors.borderLight),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.logout, color: QuickServeColors.statusRed),
                          title: const Text(
                            'Log Out',
                            style: TextStyle(
                              color: QuickServeColors.statusRed,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: QuickServeColors.statusRed),
                          onTap: onLogoutTap ?? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Session logged out.')),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar (Profile tab active: index 3)
            AppBottomNav(
              currentIndex: 3,
              onTap: (idx) {
                if (onBottomNavTap != null) {
                  onBottomNavTap!(idx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: QuickServeColors.borderLight),
        ),
        child: Column(
          children: List.generate(items.length, (idx) {
            return Column(
              children: [
                items[idx],
                if (idx < items.length - 1)
                  const Divider(height: 1, color: QuickServeColors.borderLight),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: QuickServeColors.textDark, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: QuickServeColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: QuickServeColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: (badgeColor ?? QuickServeColors.statusGreen).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor ?? QuickServeColors.statusGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Icon(Icons.chevron_right, color: QuickServeColors.textMuted, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
