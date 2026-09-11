import 'package:flutter/material.dart';
import '../core/theme.dart';

class ScheduledRidesAdvanceBookingsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onSosTap;

  const ScheduledRidesAdvanceBookingsScreen({
    super.key,
    this.onBackTap,
    this.onSosTap,
  });

  @override
  State<ScheduledRidesAdvanceBookingsScreen> createState() => _ScheduledRidesAdvanceBookingsScreenState();
}

class _ScheduledRidesAdvanceBookingsScreenState extends State<ScheduledRidesAdvanceBookingsScreen> {
  int _selectedTab = 0; // 0: Upcoming, 1: Completed, 2: Cancelled

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
          'Scheduled Rides',
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
            // Filter Tabs
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
                    _buildTab('Upcoming (2)', 0),
                    _buildTab('Completed', 1),
                    _buildTab('Cancelled', 2),
                  ],
                ),
              ),
            ),

            // Rides List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildScheduledCard(
                    dateTime: 'Tomorrow, 06:00 AM',
                    fare: '₹ 620',
                    pickup: 'Sector 62, Noida',
                    drop: 'IGI Airport Terminal 3, New Delhi',
                    passenger: 'Aarav Mehta',
                    flightNumber: 'Flight AI-102 (Domestic)',
                  ),
                  const SizedBox(height: 14),
                  _buildScheduledCard(
                    dateTime: 'Tomorrow, 02:30 PM',
                    fare: '₹ 450',
                    pickup: 'Shipra Mall, Indirapuram',
                    drop: 'Cyber Hub, DLF Phase 2 Gurgaon',
                    passenger: 'Meera Deshmukh',
                    flightNumber: null,
                  ),
                ],
              ),
            ),

            // Bottom CTA: View Open Bids
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scanning 8 new advance ride bids nearby...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Browse Open Advance Bids',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? QuickServeColors.primaryOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : QuickServeColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduledCard({
    required String dateTime,
    required String fare,
    required String pickup,
    required String drop,
    required String passenger,
    String? flightNumber,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.alarm, color: QuickServeColors.primaryOrange, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    dateTime,
                    style: const TextStyle(
                      color: QuickServeColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                fare,
                style: const TextStyle(
                  color: QuickServeColors.primaryOrange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: QuickServeColors.statusGreen, shape: BoxShape.circle),
                  ),
                  Container(width: 2, height: 26, color: const Color(0xFFCBD5E1)),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: QuickServeColors.statusRed, shape: BoxShape.circle),
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
                      style: const TextStyle(color: QuickServeColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      drop,
                      style: const TextStyle(color: QuickServeColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (flightNumber != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '✈ $flightNumber',
                style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: QuickServeColors.borderLight),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passenger: $passenger',
                style: const TextStyle(color: QuickServeColors.textSecondary, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Confirmed',
                  style: TextStyle(color: QuickServeColors.statusGreen, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
