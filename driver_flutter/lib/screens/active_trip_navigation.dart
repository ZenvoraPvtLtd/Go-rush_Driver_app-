import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/maps_provider.dart';
import '../widgets/safe_avatar.dart';

class ActiveTripNavigationScreen extends StatefulWidget {
  final VoidCallback? onEndTrip; // or onArrived
  final VoidCallback? onChatTap;
  final VoidCallback? onSosTap;
  final VoidCallback? onCallTap;

  const ActiveTripNavigationScreen({
    super.key,
    this.onEndTrip,
    this.onChatTap,
    this.onSosTap,
    this.onCallTap,
  });

  @override
  State<ActiveTripNavigationScreen> createState() => _ActiveTripNavigationScreenState();
}

class _ActiveTripNavigationScreenState extends State<ActiveTripNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      body: Stack(
        children: [
          // Full Screen Light Navigation Map
          const Positioned.fill(
            child: LightNavigationMapView(),
          ),

          // Top Turn-by-Turn Navigation Header Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: QuickServeColors.textDark,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: QuickServeColors.primaryOrange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.turn_right, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'In 200m Turn Right',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Sector 62 Main Ring Road • Toward CP',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '45 km/h',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating SOS Action Button
          Positioned(
            right: 16,
            bottom: 210,
            child: FloatingActionButton.small(
              heroTag: 'nav_sos_btn',
              backgroundColor: QuickServeColors.statusRed,
              onPressed: widget.onSosTap,
              child: const Icon(Icons.warning, color: Colors.white, size: 20),
            ),
          ),

          // Bottom Floating Navigation & Passenger Card
          Positioned(
            left: 14,
            right: 14,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: QuickServeColors.borderLight),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Passenger Row with Call & Chat Buttons
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: QuickServeColors.borderLight, width: 1.5),
                        ),
                        child: const SafeAvatar(
                          imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
                          radius: 20,
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
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '16.4 km • 32 min remaining',
                              style: TextStyle(
                                color: QuickServeColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Call Button
                      IconButton(
                        onPressed: widget.onCallTap ?? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calling passenger Priya Sharma...')),
                          );
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(color: QuickServeColors.borderLight),
                          ),
                          child: const Icon(Icons.phone, color: QuickServeColors.textDark, size: 18),
                        ),
                      ),
                      // Chat Button
                      IconButton(
                        onPressed: widget.onChatTap,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(color: QuickServeColors.borderLight),
                          ),
                          child: const Icon(Icons.chat_bubble_outline, color: QuickServeColors.primaryOrange, size: 18),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 22, color: QuickServeColors.borderLight),

                  // Arrived CTA Button (Transitions to Screen 12 Passenger Trip Management)
                  ElevatedButton(
                    onPressed: widget.onEndTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: QuickServeColors.statusGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Arrived at Pickup',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
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
}
