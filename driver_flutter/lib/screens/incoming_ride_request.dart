import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/maps_provider.dart';
import '../widgets/safe_avatar.dart';

class IncomingRideRequestScreen extends StatefulWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onSosTap;
  final Function(int)? onBottomNavTap;

  const IncomingRideRequestScreen({
    super.key,
    this.onAccept,
    this.onDecline,
    this.onSosTap,
    this.onBottomNavTap,
  });

  @override
  State<IncomingRideRequestScreen> createState() => _IncomingRideRequestScreenState();
}

class _IncomingRideRequestScreenState extends State<IncomingRideRequestScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _secondsLeft = 26;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..addListener(() {
        final remaining = (26 * (1 - _animController.value)).ceil();
        if (remaining != _secondsLeft && mounted) {
          setState(() {
            _secondsLeft = remaining;
          });
        }
      });
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      body: Stack(
        children: [
          // Background Light Vector Map showing pickup and drop points
          const Positioned.fill(
            child: LightMapView(),
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.location_on, color: QuickServeColors.primaryOrange, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Incoming Request',
                            style: TextStyle(
                              color: QuickServeColors.textDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onSosTap,
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: QuickServeColors.statusRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Incoming Request Modal / Card
          Positioned(
            left: 12,
            right: 12,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: QuickServeColors.borderLight),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title & Countdown Timer Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Ride Request',
                        style: TextStyle(
                          color: QuickServeColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: QuickServeColors.primaryOrange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: QuickServeColors.primaryOrange, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer, color: QuickServeColors.primaryOrange, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '00:${_secondsLeft.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: QuickServeColors.primaryOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Passenger Info Row
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: QuickServeColors.borderLight, width: 1.5),
                        ),
                        child: const SafeAvatar(
                          imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
                          radius: 22,
                          fallbackText: 'PS',
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priya Sharma',
                              style: TextStyle(
                                color: QuickServeColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                                SizedBox(width: 3),
                                Text(
                                  '4.8',
                                  style: TextStyle(
                                    color: QuickServeColors.textDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '(120 rides)',
                                  style: TextStyle(
                                    color: QuickServeColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Prime Sedan',
                          style: TextStyle(
                            color: QuickServeColors.statusGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: QuickServeColors.borderLight),

                  // Route Pickup & Drop
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: QuickServeColors.statusGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 32,
                            color: const Color(0xFFCBD5E1),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: QuickServeColors.statusRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup (2.1 km away)',
                              style: TextStyle(
                                color: QuickServeColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Sector 62, Noida',
                              style: TextStyle(
                                color: QuickServeColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Drop Destination',
                              style: TextStyle(
                                color: QuickServeColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Connaught Place, New Delhi',
                              style: TextStyle(
                                color: QuickServeColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: QuickServeColors.borderLight),

                  // Trip Metrics: Distance, Est. Fare, Est. Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricColumn('Distance', '16.4 km'),
                      Container(width: 1, height: 28, color: QuickServeColors.borderLight),
                      _buildMetricColumn('Est. Fare', '₹ 362', isBoldOrange: true),
                      Container(width: 1, height: 28, color: QuickServeColors.borderLight),
                      _buildMetricColumn('Est. Time', '32 min'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Accept & Reject Action Buttons
                  Row(
                    children: [
                      // Reject Button
                      Expanded(
                        flex: 4,
                        child: OutlinedButton(
                          onPressed: widget.onDecline,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: QuickServeColors.statusRed, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            foregroundColor: QuickServeColors.statusRed,
                          ),
                          child: const Text(
                            '✕ Reject',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Accept Button
                      Expanded(
                        flex: 6,
                        child: ElevatedButton(
                          onPressed: widget.onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: QuickServeColors.statusGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: const Text(
                            '✓ Accept',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, {bool isBoldOrange = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: QuickServeColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isBoldOrange ? QuickServeColors.primaryOrange : QuickServeColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
