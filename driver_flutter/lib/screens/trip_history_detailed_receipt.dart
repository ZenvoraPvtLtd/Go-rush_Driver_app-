import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/app_bottom_nav.dart';

class TripHistoryDetailedReceiptScreen extends StatefulWidget {
  final VoidCallback? onSosTap;
  final Function(int)? onBottomNavTap;

  const TripHistoryDetailedReceiptScreen({
    super.key,
    this.onSosTap,
    this.onBottomNavTap,
  });

  @override
  State<TripHistoryDetailedReceiptScreen> createState() => _TripHistoryDetailedReceiptScreenState();
}

class _TripHistoryDetailedReceiptScreenState extends State<TripHistoryDetailedReceiptScreen> {
  int _selectedTab = 0; // 0: Completed, 1: Cancelled

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trip History',
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
            // Tabs: Completed / Cancelled
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? QuickServeColors.primaryOrange : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Completed (42)',
                              style: TextStyle(
                                color: _selectedTab == 0 ? Colors.white : QuickServeColors.textSecondary,
                                fontSize: 13,
                                fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? QuickServeColors.primaryOrange : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Cancelled (2)',
                              style: TextStyle(
                                color: _selectedTab == 1 ? Colors.white : QuickServeColors.textSecondary,
                                fontSize: 13,
                                fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Trips List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTripCard(
                    date: 'Today, 09:30 AM',
                    fare: '₹ 362',
                    pickup: 'Sector 62, Noida',
                    drop: 'Connaught Place, New Delhi',
                    distance: '16.4 km',
                    duration: '32 min',
                    passenger: 'Priya Sharma',
                    isCompleted: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTripCard(
                    date: 'Today, 07:15 AM',
                    fare: '₹ 820',
                    pickup: 'Sector 18, Noida',
                    drop: 'Cyber City, Gurgaon',
                    distance: '38.2 km',
                    duration: '55 min',
                    passenger: 'Rohan Verma',
                    isCompleted: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTripCard(
                    date: 'Yesterday, 08:45 PM',
                    fare: '₹ 410',
                    pickup: 'DLF Phase 2, Gurgaon',
                    drop: 'Sector 62, Noida',
                    distance: '34.0 km',
                    duration: '48 min',
                    passenger: 'Ananya Roy',
                    isCompleted: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTripCard(
                    date: 'Yesterday, 04:10 PM',
                    fare: '₹ 240',
                    pickup: 'Connaught Place',
                    drop: 'Saket City Center',
                    distance: '14.2 km',
                    duration: '28 min',
                    passenger: 'Kunal Kapoor',
                    isCompleted: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Navigation Bar (History tab active: index 2)
            AppBottomNav(
              currentIndex: 2,
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

  Widget _buildTripCard({
    required String date,
    required String fare,
    required String pickup,
    required String drop,
    required String distance,
    required String duration,
    required String passenger,
    required bool isCompleted,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Fare Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                fare,
                style: const TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Pickup & Drop
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: QuickServeColors.statusGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 26,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: QuickServeColors.statusRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup,
                      style: const TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      drop,
                      style: const TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 13,
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

          const SizedBox(height: 12),
          const Divider(height: 1, color: QuickServeColors.borderLight),
          const SizedBox(height: 10),

          // Passenger & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$passenger • $distance • $duration',
                  style: const TextStyle(
                    color: QuickServeColors.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: QuickServeColors.statusGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
