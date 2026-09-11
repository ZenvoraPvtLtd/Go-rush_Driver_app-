import 'dart:async';
import 'package:flutter/material.dart';

enum DemoScreen {
  splashScreen, // 01
  loginRegister, // 02
  otpVerification, // 03
  driverProfileSetup, // 04
  uploadDocuments, // 05
  bankDetails, // 06
  termsConditions, // 07
  registrationComplete, // 08
  driverHomeDashboard, // 09 (Startup)
  incomingRideRequest, // 10
  activeTripNavigation, // 11
  passengerTripManagement, // 12
  tripCompletion, // 13
  fareBreakdown, // 14
  earningsInstantPayout, // 15
  tripHistoryDetailedReceipt, // 16
  notificationCenterAlerts, // 17
  safetyHubSosCenter, // 18
  helpCenterSupportTickets, // 19
  driverProfileVehicleSettings, // 20
  vehicleManagement, // 21
  scheduledRidesAdvanceBookings, // 22
  ratingsReviewsDisputeCenter, // 23
  supportTicketsScreen, // 24
  adminPanelFleet, // 25
}

class DemoStepInfo {
  final DemoScreen screen;
  final String title;
  final String codeName;
  final String subtitle;

  const DemoStepInfo({
    required this.screen,
    required this.title,
    required this.codeName,
    required this.subtitle,
  });
}

class DemoFlowController extends ChangeNotifier {
  static const int totalSeconds = 6;
  static const int tickIntervalMs = 100;
  static const int totalTicks = (totalSeconds * 1000) ~/ tickIntervalMs;

  static const List<DemoStepInfo> steps = [
    DemoStepInfo(
      screen: DemoScreen.splashScreen,
      title: '01 — Splash Screen',
      codeName: 'splash_screen',
      subtitle: 'Drive • Earn • Grow • Dark #121212',
    ),
    DemoStepInfo(
      screen: DemoScreen.loginRegister,
      title: '02 — Login / Register',
      codeName: 'driver_login_registration',
      subtitle: 'Phone Number & OTP Authentication',
    ),
    DemoStepInfo(
      screen: DemoScreen.otpVerification,
      title: '03 — OTP Verification',
      codeName: 'otp_verification_liveness',
      subtitle: '6-digit OTP & Resend Timer',
    ),
    DemoStepInfo(
      screen: DemoScreen.driverProfileSetup,
      title: '04 — Driver Profile Setup',
      codeName: 'driver_profile_setup',
      subtitle: 'Rohit Sharma, DOB & Contact Details',
    ),
    DemoStepInfo(
      screen: DemoScreen.uploadDocuments,
      title: '05 — Upload Documents',
      codeName: 'upload_documents_screen',
      subtitle: 'DL, RC, Insurance & Verification',
    ),
    DemoStepInfo(
      screen: DemoScreen.bankDetails,
      title: '06 — Bank Details / UPI',
      codeName: 'bank_details_screen',
      subtitle: 'HDFC Bank, Account & IFSC Payouts',
    ),
    DemoStepInfo(
      screen: DemoScreen.termsConditions,
      title: '07 — Terms & Conditions',
      codeName: 'terms_conditions_screen',
      subtitle: 'Partner Agreement & Driver Safety Policy',
    ),
    DemoStepInfo(
      screen: DemoScreen.registrationComplete,
      title: '08 — Registration Complete',
      codeName: 'registration_complete_screen',
      subtitle: 'Profile Submitted & Approval Status',
    ),
    DemoStepInfo(
      screen: DemoScreen.driverHomeDashboard,
      title: '09 — Driver Home / Dashboard',
      codeName: 'driver_home_dashboard',
      subtitle: 'Online • Sector 62, Noida • ₹1,240 Today',
    ),
    DemoStepInfo(
      screen: DemoScreen.incomingRideRequest,
      title: '10 — Incoming Ride Request',
      codeName: 'incoming_ride_request',
      subtitle: 'Priya Sharma • ₹362 • 16.4 km • CP Delhi',
    ),
    DemoStepInfo(
      screen: DemoScreen.activeTripNavigation,
      title: '11 — Navigation & Live Tracking',
      codeName: 'active_trip_navigation',
      subtitle: 'Light Map • Blue Route • Arrived CTA',
    ),
    DemoStepInfo(
      screen: DemoScreen.passengerTripManagement,
      title: '12 — Passenger Trip Management',
      codeName: 'passenger_trip_management',
      subtitle: 'Trip in Progress • Call/Chat • Start Trip',
    ),
    DemoStepInfo(
      screen: DemoScreen.tripCompletion,
      title: '13 — Trip Completion',
      codeName: 'trip_completion_screen',
      subtitle: 'Trip Completed • ₹362 Total • ₹282 Earnings',
    ),
    DemoStepInfo(
      screen: DemoScreen.fareBreakdown,
      title: '14 — Fare Breakdown',
      codeName: 'fare_breakdown_screen',
      subtitle: 'Base ₹240, Distance ₹110, UPI Google Pay',
    ),
    DemoStepInfo(
      screen: DemoScreen.earningsInstantPayout,
      title: '15 — Earnings',
      codeName: 'earnings_instant_payout',
      subtitle: 'Today ₹2,480 • 12 Rides • 6h 30m',
    ),
    DemoStepInfo(
      screen: DemoScreen.tripHistoryDetailedReceipt,
      title: '16 — Trip History',
      codeName: 'trip_history_detailed_receipt',
      subtitle: 'Sector 62 to CP, Gurgaon, Noida rides',
    ),
    DemoStepInfo(
      screen: DemoScreen.notificationCenterAlerts,
      title: '17 — Notifications',
      codeName: 'notification_center_alerts',
      subtitle: 'Ride Requests, Payments, Document Expiry',
    ),
    DemoStepInfo(
      screen: DemoScreen.safetyHubSosCenter,
      title: '18 — Safety & SOS',
      codeName: 'safety_hub_sos_center',
      subtitle: 'Large Red SOS Button & Emergency Contacts',
    ),
    DemoStepInfo(
      screen: DemoScreen.helpCenterSupportTickets,
      title: '19 — Support',
      codeName: 'help_center_support_tickets',
      subtitle: 'Help Center & Raise Support Tickets',
    ),
    DemoStepInfo(
      screen: DemoScreen.driverProfileVehicleSettings,
      title: '20 — Driver Profile & Settings',
      codeName: 'driver_profile_vehicle_settings',
      subtitle: 'Rohit Sharma, Vehicle, Documents & Logout',
    ),
    DemoStepInfo(
      screen: DemoScreen.vehicleManagement,
      title: '21 — Vehicle Management',
      codeName: 'vehicle_management_screen',
      subtitle: 'Honda City DL 01 AB 1234 • Verified',
    ),
    DemoStepInfo(
      screen: DemoScreen.scheduledRidesAdvanceBookings,
      title: '22 — Scheduled Rides',
      codeName: 'scheduled_rides_advance_bookings',
      subtitle: 'Tomorrow 06:00 AM • Airport ₹620',
    ),
    DemoStepInfo(
      screen: DemoScreen.ratingsReviewsDisputeCenter,
      title: '23 — Ratings & Reviews',
      codeName: 'ratings_reviews_dispute_center',
      subtitle: '4.8 ★ (138 ratings) • Breakdown & Reviews',
    ),
    DemoStepInfo(
      screen: DemoScreen.supportTicketsScreen,
      title: '24 — Support Tickets',
      codeName: 'support_tickets_screen',
      subtitle: 'Active Tickets & Dispute Resolution',
    ),
    DemoStepInfo(
      screen: DemoScreen.adminPanelFleet,
      title: '25 — Admin Panel (Web)',
      codeName: 'fleet_admin_screen',
      subtitle: 'QuickServe Admin • Dark Sidebar • Fleet Table',
    ),
  ];

  late int _currentIndex;
  int _currentTick = 0;
  bool _isPlaying = false; // By default paused on Driver Home Dashboard so user can inspect
  bool _isPausedByUser = true;
  Timer? _timer;

  int get currentIndex => _currentIndex;
  double get progress => (_currentTick / totalTicks).clamp(0.0, 1.0);
  double get remainingSeconds => ((totalTicks - _currentTick) * tickIntervalMs / 1000.0).clamp(0.0, totalSeconds.toDouble());
  bool get isPlaying => _isPlaying;
  bool get isPausedByUser => _isPausedByUser;
  DemoStepInfo get currentStep => steps[_currentIndex];
  DemoScreen get currentScreen => currentStep.screen;

  DemoFlowController({DemoScreen initialScreen = DemoScreen.driverHomeDashboard, bool autoStart = false}) {
    final idx = steps.indexWhere((s) => s.screen == initialScreen);
    _currentIndex = idx != -1 ? idx : 8; // Screen 09 Driver Home Dashboard default
    if (autoStart) {
      start();
    }
  }

  void start() {
    _timer?.cancel();
    _isPlaying = true;
    _isPausedByUser = false;
    _currentTick = 0;
    _timer = Timer.periodic(const Duration(milliseconds: tickIntervalMs), _onTick);
    notifyListeners();
  }

  void _onTick(Timer timer) {
    if (!_isPlaying) return;
    _currentTick++;
    if (_currentTick >= totalTicks) {
      _currentTick = 0;
      _currentIndex = (_currentIndex + 1) % steps.length;
    }
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause(userInitiated: true);
    } else {
      resume();
    }
  }

  void pause({bool userInitiated = true}) {
    if (_isPlaying) {
      _isPlaying = false;
      _isPausedByUser = userInitiated;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void resume() {
    _isPlaying = true;
    _isPausedByUser = false;
    _currentTick = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: tickIntervalMs), _onTick);
    notifyListeners();
  }

  void userInteracted({bool pauseAuto = true}) {
    if (pauseAuto) {
      pause(userInitiated: true);
    } else {
      _currentTick = 0;
      notifyListeners();
    }
  }

  void next() {
    _currentIndex = (_currentIndex + 1) % steps.length;
    _currentTick = 0;
    notifyListeners();
  }

  void previous() {
    _currentIndex = (_currentIndex - 1 + steps.length) % steps.length;
    _currentTick = 0;
    notifyListeners();
  }

  void jumpTo(int index) {
    if (index >= 0 && index < steps.length) {
      _currentIndex = index;
      _currentTick = 0;
      notifyListeners();
    }
  }

  void jumpToScreen(DemoScreen screen) {
    final idx = steps.indexWhere((s) => s.screen == screen);
    if (idx != -1) {
      jumpTo(idx);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
