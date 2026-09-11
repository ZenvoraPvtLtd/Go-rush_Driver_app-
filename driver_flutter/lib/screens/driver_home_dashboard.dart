import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/maps_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/safe_avatar.dart';

class DriverHomeDashboardScreen extends StatefulWidget {
  final VoidCallback? onSosTap;
  final VoidCallback? onIncomingRequestTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onEarningsTap;
  final VoidCallback? onTripsTap;
  final VoidCallback? onIncentivesTap;
  final VoidCallback? onRatingsTap;
  final VoidCallback? onSaathiAiTap;
  final VoidCallback? onNotificationTap;
  final Function(int)? onBottomNavTap;

  const DriverHomeDashboardScreen({
    super.key,
    this.onSosTap,
    this.onIncomingRequestTap,
    this.onProfileTap,
    this.onEarningsTap,
    this.onTripsTap,
    this.onIncentivesTap,
    this.onRatingsTap,
    this.onSaathiAiTap,
    this.onNotificationTap,
    this.onBottomNavTap,
  });

  @override
  State<DriverHomeDashboardScreen> createState() => _DriverHomeDashboardScreenState();
}

class _DriverHomeDashboardScreenState extends State<DriverHomeDashboardScreen> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: Rohit Sharma & Online Status
            _buildTopBar(),

            // Content naturally distributed across available screen height (no empty space)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availHeight = constraints.maxHeight;

                  // Responsively adapt section sizes so content naturally fills the viewport
                  // while guaranteeing SOS + Support Hub sits directly above bottom nav with professional spacing
                  final bool isCompact = availHeight < 620;

                  final double padV = (availHeight * 0.012).clamp(6.0, 9.0);
                  final double bottomMargin = (availHeight * 0.018).clamp(8.0, 14.0);

                  // Calibrated map height and gap scaling so content naturally fills available viewport
                  // without pushing SOS behind bottom navigation
                  final double mapHeight = (availHeight < 680)
                      ? ((availHeight - 540.0) * 0.15 + 105.0).clamp(105.0, 125.0)
                      : ((availHeight - 680.0) * 0.35 + 130.0).clamp(130.0, 220.0);
                  final double gap = (availHeight < 680)
                      ? 8.5
                      : ((availHeight - 680.0) * 0.03 + 9.0).clamp(9.0, 15.0);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: padV),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Embedded Light Map Card with Current Location Pin
                        _buildMapSection(mapHeight),

                        SizedBox(height: gap),

                        // 4 Metrics Grid (2x2)
                        _buildMetricsGrid(isCompact),

                        SizedBox(height: gap),

                        // QuickServe Incoming Request Banner (Ride Flow Launcher)
                        _buildIncomingRequestBanner(isCompact),

                        SizedBox(height: gap),

                        // Quick Actions Row (Safety SOS & Support Hub)
                        _buildQuickActionsRow(isCompact),

                        SizedBox(height: bottomMargin),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 4-Tab Bottom Navigation Bar
            AppBottomNav(
              currentIndex: 0, // Home
              onTap: (idx) {
                if (widget.onBottomNavTap != null) {
                  widget.onBottomNavTap!(idx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: QuickServeColors.borderLight, width: 1)),
      ),
      child: Row(
        children: [
          // Driver Avatar
          GestureDetector(
            onTap: widget.onProfileTap,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: QuickServeColors.primaryOrange, width: 2),
              ),
              child: const SafeAvatar(
                imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                radius: 19,
                fallbackText: 'RS',
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Driver Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Good Morning,',
                  style: TextStyle(
                    color: QuickServeColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Rohit Sharma',
                  style: TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Notification Bell
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: QuickServeColors.textDark, size: 22),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: QuickServeColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: widget.onNotificationTap,
          ),

          const SizedBox(width: 4),

          // Online / Offline Switch Pill
          GestureDetector(
            onTap: () {
              setState(() {
                _isOnline = !_isOnline;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isOnline ? const Color(0xFFE8F8EE) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isOnline ? QuickServeColors.statusGreen : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _isOnline ? QuickServeColors.statusGreen : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: _isOnline ? QuickServeColors.statusGreen : const Color(0xFF64748B),
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
  }

  Widget _buildMapSection(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Light vector map
          const LightMapView(),

          // Location Overlay Badge at Top Left
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: QuickServeColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: QuickServeColors.primaryOrange, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Current Location: Sector 62, Noida',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.gps_fixed, color: QuickServeColors.textMuted, size: 14),
                ],
              ),
            ),
          ),

          // High Demand Surge Chip at Bottom Right
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: QuickServeColors.primaryOrange,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: QuickServeColors.primaryOrange.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, color: Colors.white, size: 13),
                  SizedBox(width: 3),
                  Text(
                    'High Demand Zone (1.4x)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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
  }

  Widget _buildMetricsGrid(bool isCompact) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.directions_car_filled_outlined,
                iconColor: QuickServeColors.primaryOrange,
                iconBg: const Color(0xFFFFECE6),
                title: 'Available Requests',
                value: '5',
                subtitle: 'in 2 km radius',
                isCompact: isCompact,
                onTap: widget.onIncomingRequestTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: QuickServeColors.statusGreen,
                iconBg: const Color(0xFFE8F8EE),
                title: "Today's Earnings",
                value: '₹ 1,240',
                subtitle: '+₹360 incentive',
                isCompact: isCompact,
                onTap: widget.onEarningsTap,
              ),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 6 : 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
                title: 'Completed Rides',
                value: '12',
                subtitle: '98% acceptance',
                isCompact: isCompact,
                onTap: widget.onTripsTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.access_time,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFFF5F3FF),
                title: 'Online Hours',
                value: '5h 20m',
                subtitle: 'Target: 8h',
                isCompact: isCompact,
                onTap: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    required String subtitle,
    required bool isCompact,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 12,
          vertical: isCompact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: QuickServeColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: isCompact ? 30 : 34,
                  height: isCompact ? 30 : 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: isCompact ? 16 : 18),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, color: QuickServeColors.textMuted, size: isCompact ? 10 : 11),
              ],
            ),
            SizedBox(height: isCompact ? 5 : 7),
            Text(
              value,
              style: TextStyle(
                color: QuickServeColors.textDark,
                fontSize: isCompact ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: QuickServeColors.textSecondary,
                fontSize: isCompact ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(
                color: QuickServeColors.textMuted,
                fontSize: isCompact ? 9 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingRequestBanner(bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.primaryOrange.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: QuickServeColors.primaryOrange.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 14,
        vertical: isCompact ? 8 : 11,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 6 : 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.ring_volume, color: QuickServeColors.primaryOrange, size: isCompact ? 18 : 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ride Request Available!',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Priya Sharma • Sector 62 to Connaught Place',
                      style: TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: isCompact ? 11 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '₹ 362',
                  style: TextStyle(
                    color: QuickServeColors.statusGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 10),
          ElevatedButton(
            onPressed: widget.onIncomingRequestTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: QuickServeColors.primaryOrange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isCompact ? 9 : 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'View Incoming Request (Screen 10)',
                    style: TextStyle(fontSize: isCompact ? 13 : 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(bool isCompact) {
    return Row(
      children: [
        // SOS Button
        Expanded(
          child: GestureDetector(
            onTap: widget.onSosTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isCompact ? 10 : 12,
                horizontal: isCompact ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: QuickServeColors.statusRed, size: 17),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Emergency SOS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: QuickServeColors.statusRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Support Hub
        Expanded(
          child: GestureDetector(
            onTap: widget.onSaathiAiTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isCompact ? 10 : 12,
                horizontal: isCompact ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: QuickServeColors.borderLight),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.headset_mic_outlined, color: QuickServeColors.textDark, size: 17),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Support Hub',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
