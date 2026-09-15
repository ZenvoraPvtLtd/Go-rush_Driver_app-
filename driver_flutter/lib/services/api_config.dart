import 'package:flutter/foundation.dart';

/// Centralized API Configuration for GoRush Driver Partner Application
class ApiConfig {
  /// Optional custom base URL override for staging, testing, or custom deployments
  static String? customBaseUrl;

  /// Default port for Node.js / Express backend
  static const int defaultPort = 5000;

  /// Public HTTPS Tunnel URL (100% reachable over any Wi-Fi, 4G, 5G)
  static const String publicTunnelUrl = 'https://random-decor-liable-stocks.trycloudflare.com';

  /// Primary LAN IP of the host machine running the backend (Windows PC)
  static const String currentLanHost = '10.38.243.206';
  static const String secondaryLanHost = '192.168.0.186';

  /// Candidate base URLs in priority order for physical Android phone:
  /// 1. Direct Local Wi-Fi / Host LAN IP (http://10.38.243.206:5000) - 100% reachable from physical phone
  /// 2. Localhost via USB ADB reverse (http://localhost:5000)
  /// 3. Localhost loopback (http://127.0.0.1:5000)
  /// 4. Android Emulator host (http://10.0.2.2:5000)
  static List<String> get candidateBaseUrls {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return [customBaseUrl!];
    }

    if (kIsWeb) {
      return ['http://localhost:$defaultPort'];
    }

    return [
      'http://$currentLanHost:$defaultPort',
      'http://localhost:$defaultPort',
      'http://127.0.0.1:$defaultPort',
      'http://10.0.2.2:$defaultPort',
    ];
  }

  /// Primary base URL for Android physical device connecting to Node.js backend
  /// NOTE: Physical phones cannot connect to localhost without ADB reverse; use LAN IP.
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:$defaultPort';
    }
    return 'http://$currentLanHost:$defaultPort';
  }

  // Endpoints
  static const String healthEndpoint = '/api/health';
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String meEndpoint = '/api/auth/me';
  static const String changePasswordEndpoint = '/api/auth/change-password';
  static const String updateProfileEndpoint = '/api/auth/profile';
  static const String vehiclesEndpoint = '/api/auth/vehicles';

  // Phase 5: Core Ride & Driver endpoints
  static const String driverStatusEndpoint = '/api/driver/status';
  static const String ridesAvailableEndpoint = '/api/rides/available';
  static const String ridesActiveEndpoint = '/api/rides/active';
  static const String ridesHistoryEndpoint = '/api/rides/history';
  static const String ridesEarningsEndpoint = '/api/rides/earnings';

  // Request timeouts
  static const Duration requestTimeout = Duration(seconds: 10);
  static const Duration healthCheckTimeout = Duration(seconds: 5);

  /// Standard HTTP Headers
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}
