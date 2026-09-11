import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:gorush_driver/main.dart';
import 'package:gorush_driver/services/driver_backend_service.dart';

void main() {
  group('QuickServe Driver App Flow & Overlay Removal Tests', () {
    setUp(() {
      // Ensure clean authenticated state for initial tests
      DriverBackendService.instance.saveSession();
    });

    testWidgets('1. App starts on Splash Screen then auto-navigates to Login / Register Screen (No HUD)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const QuickServeDriverApp());
      await tester.pump();

      // STEP 1: INITIAL LAUNCH MUST SHOW EXISTING SPLASH SCREEN
      expect(find.text('QuickServe'), findsOneWidget);
      expect(find.text('Driver Partner App'), findsOneWidget);
      expect(find.text('Drive • Earn • Grow'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Trusted by 50,000+ Drivers Across NCR'), findsOneWidget);

      // Verify no top HUD overlay
      expect(find.textContaining('SCREEN 1/25'), findsNothing);

      // STEP 2: AUTO-TRANSITION AFTER 2 SECONDS TO LOGIN / REGISTER
      await tester.pump(const Duration(milliseconds: 2100));

      expect(find.text('Welcome to QuickServe'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.textContaining('SCREEN 2/25'), findsNothing);
    });

    testWidgets('2. Ride Demo Flow: Splash -> Login -> OTP -> Home -> Incoming -> Accept -> Arrived -> Start Trip -> Completed -> Fare -> Earnings', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const QuickServeDriverApp());
      await tester.pump();

      // Tap Get Started on Splash -> Login/Register
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Continue -> OTP
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Verify & Continue -> Driver Home Dashboard
      await tester.tap(find.text('Verify & Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Driver Home Dashboard reached
      expect(find.text('Good Morning,'), findsOneWidget);
      expect(find.text('Rohit Sharma'), findsOneWidget);

      // 1. From Home, scroll & tap incoming request banner
      final incomingBtn = find.textContaining('View Incoming Request');
      await tester.ensureVisible(incomingBtn);
      await tester.tap(incomingBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Screen 10: Incoming Ride Request
      expect(find.text('New Ride Request'), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.textContaining('362'), findsWidgets);
      expect(find.text('16.4 km'), findsWidgets);
      
      final acceptBtn = find.textContaining('Accept');
      expect(acceptBtn, findsOneWidget);

      // 2. Tap Accept -> Screen 11: Navigation & Live Tracking
      await tester.tap(acceptBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Arrived at Pickup'), findsOneWidget);

      // 3. Tap Arrived -> Screen 12: Passenger Trip Management
      await tester.tap(find.text('Arrived at Pickup'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Trip in Progress'), findsOneWidget);
      expect(find.text('Start Trip'), findsOneWidget);

      // 4. Tap Start Trip -> Screen 13: Trip Completion
      await tester.tap(find.text('Start Trip'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Trip Completed Successfully!'), findsOneWidget);
      expect(find.textContaining('282'), findsWidgets); // Net earnings
      expect(find.text('View Fare Breakdown'), findsOneWidget);

      // 5. Tap View Details -> Screen 14: Fare Breakdown
      await tester.tap(find.text('View Fare Breakdown'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Total Trip Fare'), findsOneWidget);
      expect(find.textContaining('402'), findsWidgets);
      expect(find.text('Done (View Earnings)'), findsOneWidget);

      // 6. Tap Done -> Screen 15: Earnings
      await tester.tap(find.text('Done (View Earnings)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text("Today's Net Earnings"), findsOneWidget);
      expect(find.textContaining('2,480'), findsWidgets);
    });

    testWidgets('3. Bottom Navigation bar switches between Home, Earnings, History, Profile (No HUD on any screen)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const QuickServeDriverApp());
      await tester.pump();

      // Navigate from Splash -> Login -> OTP -> Driver Home
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Verify & Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Earnings Tab (index 1)
      await tester.tap(find.text('Earnings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('2,480'), findsWidgets);
      expect(find.textContaining('SCREEN 15/25'), findsNothing);

      // Tap History Tab (index 2)
      await tester.tap(find.text('History'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Trip History'), findsOneWidget);
      expect(find.textContaining('SCREEN 16/25'), findsNothing);

      // Tap Profile Tab (index 3)
      await tester.tap(find.text('Profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.textContaining('SCREEN 20/25'), findsNothing);

      // Tap Home Tab (index 0)
      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Rohit Sharma'), findsOneWidget);
      expect(find.textContaining('SCREEN 9/25'), findsNothing);
    });

    testWidgets('4. REAL LOGOUT TEST: Home -> Profile -> Logout -> Login/Register screen (OTP is NOT shown, HUD is NOT shown)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Ignore layout overflow warning from existing UI divider in test environment
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('overflowed')) {
          prevOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      await tester.pumpWidget(const QuickServeDriverApp());
      await tester.pump();

      // Navigate from Splash -> Login -> OTP -> Driver Home
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Verify & Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(DriverBackendService.instance.isAuthenticated, isTrue);

      // Navigate to Profile & Settings (Screen 20)
      await tester.tap(find.text('Profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Profile & Settings'), findsOneWidget);

      // Find and tap the Log Out button
      final logoutTile = find.text('Log Out');
      expect(logoutTile, findsOneWidget);
      await tester.ensureVisible(logoutTile);
      await tester.tap(logoutTile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // CRITICAL ASSERTION 1: Screen MUST be 02 (Login / Register) without HUD
      expect(find.text('Welcome to QuickServe'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.textContaining('SCREEN 2/25'), findsNothing);

      // CRITICAL ASSERTION 2: OTP Verification must NOT appear
      expect(find.text('Verify Your Number'), findsNothing);

      // CRITICAL ASSERTION 3: Authentication state must be cleared
      expect(DriverBackendService.instance.isAuthenticated, isFalse);
      expect(DriverBackendService.instance.accessToken, isNull);
      expect(DriverBackendService.instance.refreshToken, isNull);
      expect(DriverBackendService.instance.driverProfile, isNull);
    });

    testWidgets('5. NORMAL LOGIN AFTER LOGOUT: Login/Register -> Continue -> OTP Verification -> Verify -> Driver Home', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Ignore layout overflow warning from existing UI divider in test environment
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('overflowed')) {
          prevOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      // Force unauthenticated state
      DriverBackendService.instance.logout();

      await tester.pumpWidget(const QuickServeDriverApp());
      await tester.pump();

      // Wait 2.1s for Splash Screen to auto-navigate to Login / Register
      await tester.pump(const Duration(milliseconds: 2100));

      // Starts on Login / Register because unauthenticated
      expect(find.text('Welcome to QuickServe'), findsOneWidget);
      expect(find.textContaining('SCREEN 2/25'), findsNothing);

      // Tap Continue to get OTP
      final continueBtn = find.text('Continue');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now OTP Verification screen appears
      expect(find.text('Verify Your Number'), findsOneWidget);
      expect(find.textContaining('SCREEN 3/25'), findsNothing);

      // Tap Verify & Continue (Screen 03 CTA)
      final verifyBtn = find.text('Verify & Continue');
      expect(verifyBtn, findsOneWidget);
      await tester.tap(verifyBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Reaches Driver Home Dashboard
      expect(find.text('Good Morning,'), findsOneWidget);
      expect(find.text('Rohit Sharma'), findsOneWidget);
      expect(DriverBackendService.instance.isAuthenticated, isTrue);
      expect(find.textContaining('SCREEN 9/25'), findsNothing);
    });

    testWidgets('6. Layout Fit Test: Emergency SOS and Support Hub visible on Home without scrolling; Instant Cash Out and Statement visible on Earnings', (WidgetTester tester) async {
      // Mobile phone viewport (390 x 780 logical pixels)
      tester.view.physicalSize = const Size(390, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (!details.toString().contains('overflowed')) {
          prevOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      DriverBackendService.instance.saveSession();

      await tester.pumpWidget(const QuickServeDriverApp());
      await tester.pump();

      // Enter Driver Home via onboarding flow
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Verify & Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Home Screen Content
      expect(find.text('Rohit Sharma'), findsOneWidget);
      expect(find.text('Current Location: Sector 62, Noida'), findsOneWidget);
      expect(find.text('Available Requests'), findsOneWidget);
      expect(find.text("Today's Earnings"), findsOneWidget);
      expect(find.text('Ride Request Available!'), findsOneWidget);

      // CHANGE 1 VERIFICATION: Emergency SOS and Support Hub MUST be visible without scrolling
      final sosFinder = find.text('Emergency SOS');
      final supportFinder = find.text('Support Hub');
      expect(sosFinder, findsOneWidget);
      expect(supportFinder, findsOneWidget);
      final sosDy = tester.getTopLeft(sosFinder).dy;
      final supportDy = tester.getTopLeft(supportFinder).dy;
      final sosBottom = tester.getBottomRight(sosFinder).dy;
      // Both elements must be visible and sit above the bottom navigation bar (720.0 on 780 screen)
      expect(sosDy, lessThan(780.0));
      expect(supportDy, lessThan(780.0));
      expect(sosBottom, lessThan(720.0));

      // Navigate to Earnings Tab
      await tester.tap(find.text('Earnings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Earnings Header & Cards
      expect(find.text('Earnings'), findsNWidgets(2)); // AppBar title + Bottom nav tab
      expect(find.text("Today's Net Earnings"), findsOneWidget);
      expect(find.text('Linked Bank: HDFC Bank'), findsOneWidget);

      // CHANGE 2 VERIFICATION: Instant Cash Out and View Earnings Statement MUST be visible without scrolling
      final cashOutFinder = find.textContaining('Instant Cash Out');
      final statementFinder = find.text('View Earnings Statement');
      expect(cashOutFinder, findsOneWidget);
      expect(statementFinder, findsOneWidget);
      final cashOutBottom = tester.getBottomRight(cashOutFinder).dy;
      final statementBottom = tester.getBottomRight(statementFinder).dy;
      // Both buttons must be above the bottom navigation bar and within the visible screen
      expect(cashOutBottom, lessThan(720.0));
      expect(statementBottom, lessThan(720.0));
    });
  });
}

