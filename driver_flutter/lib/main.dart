import 'dart:async';
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/demo_controller.dart';
import 'services/driver_backend_service.dart';

// Screens 01 to 08: Onboarding
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/driver_login_registration.dart';
import 'screens/onboarding/otp_verification_liveness.dart';
import 'screens/onboarding/driver_profile_setup.dart';
import 'screens/onboarding/upload_documents_screen.dart';
import 'screens/onboarding/bank_details_screen.dart';
import 'screens/onboarding/terms_conditions_screen.dart';
import 'screens/onboarding/registration_complete_screen.dart';

// Screens 09 to 14: Core Ride Flow
import 'screens/driver_home_dashboard.dart';
import 'screens/incoming_ride_request.dart';
import 'screens/active_trip_navigation.dart';
import 'screens/passenger_trip_management.dart';
import 'screens/trip_completion_screen.dart';
import 'screens/fare_breakdown_screen.dart';

// Screens 15 to 24: Driver Operations & Management
import 'screens/earnings_instant_payout.dart';
import 'screens/trip_history_detailed_receipt.dart';
import 'screens/notification_center_alerts.dart';
import 'screens/safety_hub_sos_center.dart';
import 'screens/help_center_support_tickets.dart';
import 'screens/driver_profile_vehicle_settings.dart';
import 'screens/vehicle_management_screen.dart';
import 'screens/scheduled_rides_advance_bookings.dart';
import 'screens/ratings_reviews_dispute_center.dart';
import 'screens/support_tickets_screen.dart';

// Screen 25: Admin Web Portal
import 'screens/admin/fleet_admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DriverBackendService.instance.initSession();
  runApp(const QuickServeDriverApp());
}

class QuickServeDriverApp extends StatelessWidget {
  const QuickServeDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickServe Driver App',
      debugShowCheckedModeBanner: false,
      theme: QuickServeTheme.lightTheme,
      home: const QuickServeDriverRootFlow(),
    );
  }
}

typedef GoRushDriverApp = QuickServeDriverApp;

class QuickServeDriverRootFlow extends StatefulWidget {
  const QuickServeDriverRootFlow({super.key});

  @override
  State<QuickServeDriverRootFlow> createState() => _QuickServeDriverRootFlowState();
}

class _QuickServeDriverRootFlowState extends State<QuickServeDriverRootFlow> {
  late final DemoFlowController _demoController;
  final List<DemoScreen> _navigationHistory = [];
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    // Non-Negotiable Requirement: App MUST open directly onto Step 1 — Splash Screen (Screen 01).
    _demoController = DemoFlowController(
      initialScreen: DemoScreen.splashScreen,
      autoStart: false,
    );
    _demoController.addListener(_onControllerUpdate);

    // Automatically navigate from Splash Screen to Step 2 — Login / Register Screen after 2.0s
    _splashTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted && _demoController.currentScreen == DemoScreen.splashScreen) {
        _navigateTo(DemoScreen.loginRegister);
      }
    });
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _demoController.removeListener(_onControllerUpdate);
    _demoController.dispose();
    super.dispose();
  }

  void _handleManualInteraction({bool pause = true}) {
    _demoController.userInteracted(pauseAuto: pause);
  }

  void _navigateTo(DemoScreen screen) {
    _handleManualInteraction(pause: true);
    if (_demoController.currentScreen != screen) {
      _navigationHistory.add(_demoController.currentScreen);
    }
    _demoController.jumpToScreen(screen);
  }

  void _handleBottomNavTap(int index) {
    _handleManualInteraction(pause: true);
    switch (index) {
      case 0:
        _navigateTo(DemoScreen.driverHomeDashboard);
        break;
      case 1:
        _navigateTo(DemoScreen.earningsInstantPayout);
        break;
      case 2:
        _navigateTo(DemoScreen.tripHistoryDetailedReceipt);
        break;
      case 3:
        _navigateTo(DemoScreen.driverProfileVehicleSettings);
        break;
    }
  }

  bool _canPopCurrentRoute() {
    if (!DriverBackendService.instance.isAuthenticated) {
      // When logged out, system back button on Login/Register or Splash exits the application
      return _demoController.currentScreen == DemoScreen.loginRegister ||
          _demoController.currentScreen == DemoScreen.splashScreen;
    }
    // When authenticated on Home with no history, system back exits the app
    return _demoController.currentScreen == DemoScreen.driverHomeDashboard && _navigationHistory.isEmpty;
  }

  void _handleBackNavigation() {
    if (!DriverBackendService.instance.isAuthenticated) {
      // Driver is logged out: NEVER allow returning to any authenticated driver screens!
      if (_demoController.currentScreen == DemoScreen.otpVerification) {
        _handleManualInteraction(pause: true);
        _demoController.jumpToScreen(DemoScreen.loginRegister);
      }
      return;
    }

    if (_navigationHistory.isNotEmpty) {
      final prev = _navigationHistory.removeLast();
      _handleManualInteraction(pause: true);
      _demoController.jumpToScreen(prev);
    } else if (_demoController.currentScreen != DemoScreen.driverHomeDashboard) {
      _handleManualInteraction(pause: true);
      _demoController.jumpToScreen(DemoScreen.driverHomeDashboard);
    }
  }

  Widget _buildCurrentScreen() {
    switch (_demoController.currentScreen) {
      // 01: Splash Screen (Dark #121212)
      case DemoScreen.splashScreen:
        return SplashScreen(
          onGetStarted: () {
            _splashTimer?.cancel();
            _navigateTo(DemoScreen.loginRegister);
          },
        );

      // 02: Login / Register
      case DemoScreen.loginRegister:
        return DriverLoginRegistrationScreen(
          onBackTap: () {
            _handleManualInteraction(pause: true);
            _demoController.jumpToScreen(DemoScreen.splashScreen);
          },
          onGetOtp: () {
            _navigateTo(DemoScreen.otpVerification);
          },
        );

      // 03: OTP Verification
      case DemoScreen.otpVerification:
        return OtpVerificationLivenessScreen(
          onBackTap: () {
            _handleManualInteraction(pause: true);
            _demoController.jumpToScreen(DemoScreen.loginRegister);
          },
          onVerifySuccess: () {
            _handleManualInteraction(pause: true);
            DriverBackendService.instance.saveSession();
            _navigationHistory.clear();
            _demoController.jumpToScreen(DemoScreen.driverHomeDashboard);
          },
        );

      // 04: Driver Profile Setup
      case DemoScreen.driverProfileSetup:
        return DriverProfileSetupScreen(
          onBackTap: () {
            _navigateTo(DemoScreen.otpVerification);
          },
          onNext: () {
            _navigateTo(DemoScreen.uploadDocuments);
          },
        );

      // 05: Upload Documents
      case DemoScreen.uploadDocuments:
        return UploadDocumentsScreen(
          onBackTap: () {
            _navigateTo(DemoScreen.driverProfileSetup);
          },
          onNext: () {
            _navigateTo(DemoScreen.bankDetails);
          },
        );

      // 06: Bank Details / UPI
      case DemoScreen.bankDetails:
        return BankDetailsScreen(
          onBackTap: () {
            _navigateTo(DemoScreen.uploadDocuments);
          },
          onNext: () {
            _navigateTo(DemoScreen.termsConditions);
          },
        );

      // 07: Terms & Conditions
      case DemoScreen.termsConditions:
        return TermsConditionsScreen(
          onBackTap: () {
            _navigateTo(DemoScreen.bankDetails);
          },
          onComplete: () {
            _navigateTo(DemoScreen.registrationComplete);
          },
        );

      // 08: Registration Complete
      case DemoScreen.registrationComplete:
        return RegistrationCompleteScreen(
          onGoHome: () {
            _navigationHistory.clear();
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
        );

      // 09: Driver Home / Dashboard (The Default Startup Screen!)
      case DemoScreen.driverHomeDashboard:
        return DriverHomeDashboardScreen(
          key: const ValueKey('screen_09_home'),
          onIncomingRequestTap: () {
            _navigateTo(DemoScreen.incomingRideRequest);
          },
          onEarningsTap: () {
            _navigateTo(DemoScreen.earningsInstantPayout);
          },
          onTripsTap: () {
            _navigateTo(DemoScreen.tripHistoryDetailedReceipt);
          },
          onIncentivesTap: () {
            _navigateTo(DemoScreen.scheduledRidesAdvanceBookings);
          },
          onRatingsTap: () {
            _navigateTo(DemoScreen.ratingsReviewsDisputeCenter);
          },
          onSaathiAiTap: () {
            _navigateTo(DemoScreen.helpCenterSupportTickets);
          },
          onNotificationTap: () {
            _navigateTo(DemoScreen.notificationCenterAlerts);
          },
          onSosTap: () {
            _navigateTo(DemoScreen.safetyHubSosCenter);
          },
          onProfileTap: () {
            _navigateTo(DemoScreen.driverProfileVehicleSettings);
          },
          onBottomNavTap: _handleBottomNavTap,
        );

      // 10: Incoming Ride Request
      case DemoScreen.incomingRideRequest:
        return IncomingRideRequestScreen(
          key: const ValueKey('screen_10_incoming'),
          onAccept: () {
            _navigateTo(DemoScreen.activeTripNavigation);
          },
          onDecline: () {
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
          onSosTap: () {
            _navigateTo(DemoScreen.safetyHubSosCenter);
          },
          onBottomNavTap: _handleBottomNavTap,
        );

      // 11: Navigation & Live Tracking
      case DemoScreen.activeTripNavigation:
        return ActiveTripNavigationScreen(
          key: const ValueKey('screen_11_nav'),
          onEndTrip: () {
            _navigateTo(DemoScreen.passengerTripManagement);
          },
          onChatTap: () {
            _navigateTo(DemoScreen.passengerTripManagement);
          },
          onSosTap: () {
            _navigateTo(DemoScreen.safetyHubSosCenter);
          },
        );

      // 12: Passenger Trip Management
      case DemoScreen.passengerTripManagement:
        return PassengerTripManagementScreen(
          key: const ValueKey('screen_12_trip_mgmt'),
          onBackTap: () {
            _navigateTo(DemoScreen.activeTripNavigation);
          },
          onStartTrip: () {
            _navigateTo(DemoScreen.tripCompletion);
          },
          onCancelTrip: () {
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
        );

      // 13: Trip Completion
      case DemoScreen.tripCompletion:
        return TripCompletionScreen(
          key: const ValueKey('screen_13_completion'),
          onBackTap: () {
            _navigateTo(DemoScreen.passengerTripManagement);
          },
          onViewDetails: () {
            _navigateTo(DemoScreen.fareBreakdown);
          },
        );

      // 14: Fare Breakdown
      case DemoScreen.fareBreakdown:
        return FareBreakdownScreen(
          key: const ValueKey('screen_14_fare'),
          onBackTap: () {
            _navigateTo(DemoScreen.tripCompletion);
          },
          onDone: () {
            _navigateTo(DemoScreen.earningsInstantPayout);
          },
        );

      // 15: Earnings
      case DemoScreen.earningsInstantPayout:
        return EarningsInstantPayoutScreen(
          key: const ValueKey('screen_15_earnings'),
          onCashOutTap: () {
            _handleManualInteraction(pause: true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Instant UPI Transfer Initiated: ₹ 2,480 credited to HDFC Bank'),
                backgroundColor: QuickServeColors.statusGreen,
              ),
            );
          },
          onSosTap: () {
            _navigateTo(DemoScreen.safetyHubSosCenter);
          },
          onBottomNavTap: _handleBottomNavTap,
        );

      // 16: Trip History
      case DemoScreen.tripHistoryDetailedReceipt:
        return TripHistoryDetailedReceiptScreen(
          key: const ValueKey('screen_16_history'),
          onSosTap: () {
            _navigateTo(DemoScreen.safetyHubSosCenter);
          },
          onBottomNavTap: _handleBottomNavTap,
        );

      // 17: Notifications
      case DemoScreen.notificationCenterAlerts:
        return NotificationCenterAlertsScreen(
          key: const ValueKey('screen_17_notifications'),
          onBackTap: () {
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
          onSosTap: () {
            _navigateTo(DemoScreen.safetyHubSosCenter);
          },
        );

      // 18: Safety & SOS
      case DemoScreen.safetyHubSosCenter:
        return SafetyHubSosCenterScreen(
          key: const ValueKey('screen_18_safety'),
          onBackTap: () {
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
        );

      // 19: Support
      case DemoScreen.helpCenterSupportTickets:
        return HelpCenterSupportTicketsScreen(
          key: const ValueKey('screen_19_help'),
          onBackTap: () {
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
          onRaiseTicketTap: () {
            _navigateTo(DemoScreen.supportTicketsScreen);
          },
        );

      // 20: Driver Profile & Settings
      case DemoScreen.driverProfileVehicleSettings:
        return DriverProfileVehicleSettingsScreen(
          key: const ValueKey('screen_20_profile'),
          onBackTap: () {
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
          onVehicleTap: () {
            _navigateTo(DemoScreen.vehicleManagement);
          },
          onDocumentsTap: () {
            _navigateTo(DemoScreen.uploadDocuments);
          },
          onBankTap: () {
            _navigateTo(DemoScreen.bankDetails);
          },
          onLogoutTap: () {
            _handleManualInteraction(pause: true);
            DriverBackendService.instance.logout();
            _navigationHistory.clear();
            _demoController.jumpToScreen(DemoScreen.loginRegister);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully.'),
                  backgroundColor: QuickServeColors.primaryOrange,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          onBottomNavTap: _handleBottomNavTap,
        );

      // 21: Vehicle Management
      case DemoScreen.vehicleManagement:
        return VehicleManagementScreen(
          key: const ValueKey('screen_21_vehicle'),
          onBackTap: () {
            _navigateTo(DemoScreen.driverProfileVehicleSettings);
          },
        );

      // 22: Scheduled Rides
      case DemoScreen.scheduledRidesAdvanceBookings:
        return ScheduledRidesAdvanceBookingsScreen(
          key: const ValueKey('screen_22_scheduled'),
          onBackTap: () {
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
          onSosTap: () {
            _navigateTo(DemoScreen.safetyHubSosCenter);
          },
        );

      // 23: Ratings & Reviews
      case DemoScreen.ratingsReviewsDisputeCenter:
        return RatingsReviewsDisputeScreen(
          key: const ValueKey('screen_23_ratings'),
          onBackTap: () {
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
        );

      // 24: Support Tickets
      case DemoScreen.supportTicketsScreen:
        return SupportTicketsScreen(
          key: const ValueKey('screen_24_tickets'),
          onBackTap: () {
            _navigateTo(DemoScreen.helpCenterSupportTickets);
          },
        );

      // 25: Admin Panel (Web)
      case DemoScreen.adminPanelFleet:
        return FleetAdminOperationsScreen(
          key: const ValueKey('screen_25_admin'),
          onBack: () {
            _navigateTo(DemoScreen.driverHomeDashboard);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPopCurrentRoute(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: _buildCurrentScreen(),
    );
  }
}
