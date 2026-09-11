import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/safe_avatar.dart';

class RatingsReviewsDisputeScreen extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onDisputeTap;

  const RatingsReviewsDisputeScreen({
    super.key,
    this.onBackTap,
    this.onDisputeTap,
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
          'Ratings & Reviews',
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
              // Rating Overview Card
              Container(
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
                child: Row(
                  children: [
                    // Score Column
                    Column(
                      children: [
                        const Text(
                          '4.8',
                          style: TextStyle(
                            color: QuickServeColors.textDark,
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                            Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                            Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                            Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                            Icon(Icons.star_half, color: Color(0xFFFBBF24), size: 18),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '138 Ratings',
                          style: TextStyle(
                            color: QuickServeColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 24),

                    // Progress Bars
                    Expanded(
                      child: Column(
                        children: [
                          _buildStarBar(5, 0.65),
                          const SizedBox(height: 4),
                          _buildStarBar(4, 0.20),
                          const SizedBox(height: 4),
                          _buildStarBar(3, 0.10),
                          const SizedBox(height: 4),
                          _buildStarBar(2, 0.03),
                          const SizedBox(height: 4),
                          _buildStarBar(1, 0.02),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Badges / Compliments
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
                    const Text(
                      'Top Compliments',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge('⭐ Smooth Driving (94)'),
                        _buildBadge('✨ Clean Car (88)'),
                        _buildBadge('⏱ On-Time Arrival (76)'),
                        _buildBadge('🤝 Polite Behaviour (65)'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Recent Passenger Feedback',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildReviewCard(
                name: 'Amit Patel',
                time: '2 hours ago',
                rating: 5,
                comment: 'Polite driver, clean car, and very smooth ride on the highway!',
                avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
              ),

              const SizedBox(height: 10),

              _buildReviewCard(
                name: 'Neha Gupta',
                time: 'Yesterday',
                rating: 5,
                comment: 'Arrived on time and took the best route to avoid traffic jams in CP.',
                avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Loading all 138 customer reviews...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('View All Reviews', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarBar(int star, double ratio) {
    return Row(
      children: [
        Text(
          '$star',
          style: const TextStyle(color: QuickServeColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(ratio * 100).toInt()}%',
          style: const TextStyle(color: QuickServeColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Text(
        label,
        style: const TextStyle(color: QuickServeColors.textDark, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String time,
    required int rating,
    required String comment,
    required String avatarUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SafeAvatar(
                imageUrl: avatarUrl,
                radius: 16,
                fallbackText: name.substring(0, 1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: QuickServeColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(time, style: const TextStyle(color: QuickServeColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  rating,
                  (index) => const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(color: QuickServeColors.textSecondary, fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }
}
