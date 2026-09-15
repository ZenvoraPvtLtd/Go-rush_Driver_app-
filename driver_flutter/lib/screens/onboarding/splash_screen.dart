import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const SplashScreen({
    super.key,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF071126), // Deep Midnight Navy matching reference image
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onGetStarted,
        child: Stack(
          children: [
            // Full-Screen Background with the dark road, blue hatchback car & headlights
            Positioned.fill(
              child: Image.asset(
                'assets/splash_car_front.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackCarGraphic(),
              ),
            ),

            // Soft atmospheric gradient overlay for readability
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.40, 0.70, 1.0],
                    colors: [
                      Color(0xD9071126),
                      Color(0x33071126),
                      Colors.transparent,
                      Color(0xCC071126),
                    ],
                  ),
                ),
              ),
            ),

            // Content Overlay
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight > 600 ? screenHeight * 0.08 : 36),

                    // Top Branding: GoRush Circular Logo + Title
                    _buildGoRushPinLogo(),
                    const SizedBox(height: 14),
                    const Text(
                      'GoRush',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Driver App',
                      style: TextStyle(
                        color: Color(0xFF93C5FD), // Soft Sky Blue
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Drive • Earn • Grow',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // Bottom CTA: Get Started
                    ElevatedButton(
                      onPressed: onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5AE6),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF1E5AE6).withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Trust Tagline
                    const Text(
                      'Trusted by 50,000+ Drivers Across NCR',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoRushPinLogo() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2.5),
      ),
      child: const Center(
        child: Icon(
          Icons.electric_car_rounded,
          color: Colors.white,
          size: 38,
        ),
      ),
    );
  }

  Widget _buildFallbackCarGraphic() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF071126), Color(0xFF0F1E3D), Color(0xFF071126)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: 140,
          color: QuickServeColors.primaryOrange.withOpacity(0.6),
        ),
      ),
    );
  }
}
