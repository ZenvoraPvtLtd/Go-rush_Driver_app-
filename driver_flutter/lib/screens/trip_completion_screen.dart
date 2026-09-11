import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/safe_avatar.dart';

class TripCompletionScreen extends StatefulWidget {
  final VoidCallback? onViewDetails;
  final VoidCallback? onBackTap;

  const TripCompletionScreen({
    super.key,
    this.onViewDetails,
    this.onBackTap,
  });

  @override
  State<TripCompletionScreen> createState() => _TripCompletionScreenState();
}

class _TripCompletionScreenState extends State<TripCompletionScreen> {
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap,
        ),
        title: const Text(
          'Trip Completed',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 17,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Success Green Checkmark Icon
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F8EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: QuickServeColors.statusGreen,
                  size: 48,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Trip Completed Successfully!',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Sector 62, Noida ➔ Connaught Place, New Delhi',
                style: TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Total Fare Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: QuickServeColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Fare Collected',
                      style: TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '₹ 362',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: QuickServeColors.borderLight),
                    const SizedBox(height: 10),
                    _buildRow('Base Fare', '₹ 240'),
                    const SizedBox(height: 8),
                    _buildRow('Distance (16.4 km)', '₹ 110'),
                    const SizedBox(height: 8),
                    _buildRow('Ride Time (32 min)', '₹ 32'),
                    const SizedBox(height: 8),
                    _buildRow('Platform Fee & Taxes', '- ₹ 100', isMuted: true),
                    const SizedBox(height: 14),

                    // Net Driver Earnings Highlight
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8EE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: QuickServeColors.statusGreen.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Net Earnings:',
                            style: TextStyle(
                              color: QuickServeColors.statusGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹ 282',
                            style: TextStyle(
                              color: QuickServeColors.statusGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Rate Passenger Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SafeAvatar(
                          imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
                          radius: 16,
                          fallbackText: 'PS',
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Rate Passenger Priya Sharma',
                            style: TextStyle(
                              color: QuickServeColors.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNum = index + 1;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          icon: Icon(
                            starNum <= _selectedRating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFBBF24),
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRating = starNum;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Orange CTA View Details Button (Transitions to Screen 14 Fare Breakdown)
              ElevatedButton(
                onPressed: widget.onViewDetails,
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
                    Text(
                      'View Fare Breakdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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

  Widget _buildRow(String label, String value, {bool isMuted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isMuted ? QuickServeColors.textMuted : QuickServeColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isMuted ? QuickServeColors.textMuted : QuickServeColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
