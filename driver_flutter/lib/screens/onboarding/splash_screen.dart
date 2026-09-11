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
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Strict dark background as per master reference
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),

              // Logo & App Name
              Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: QuickServeColors.primaryOrange,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: QuickServeColors.primaryOrange.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.speed,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'QuickServe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Driver Partner App',
                    style: TextStyle(
                      color: QuickServeColors.primaryOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Drive • Earn • Grow',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              // Road Graphic Visual Representation
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1E1E1E),
                      Color(0xFF181818),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Perspective lines
                    CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: _PerspectiveRoadPainter(),
                    ),
                    // Center Car Icon
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: QuickServeColors.primaryOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: QuickServeColors.primaryOrange.withOpacity(0.5),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.directions_car, color: Colors.white, size: 36),
                    ),
                  ],
                ),
              ),

              // Bottom Get Started CTA Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: onGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: QuickServeColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Trusted by 50,000+ Drivers Across NCR',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerspectiveRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 2;

    // Perspective road edges
    canvas.drawLine(Offset(size.width * 0.35, 10), Offset(size.width * 0.1, size.height - 10), linePaint);
    canvas.drawLine(Offset(size.width * 0.65, 10), Offset(size.width * 0.9, size.height - 10), linePaint);

    // Glowing center road dashes
    final dashPaint = Paint()
      ..color = const Color(0xFFFF5722).withOpacity(0.6)
      ..strokeWidth = 3;

    for (double y = 20; y < size.height - 20; y += 30) {
      canvas.drawLine(Offset(size.width * 0.5, y), Offset(size.width * 0.5, y + 15), dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
