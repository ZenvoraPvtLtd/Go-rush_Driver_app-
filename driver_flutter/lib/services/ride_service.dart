import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'token_storage_service.dart';
import '../models/ride_model.dart';

class RideService extends ChangeNotifier {
  static final RideService instance = RideService._internal();
  factory RideService() => instance;
  RideService._internal();

  final http.Client _httpClient = http.Client();
  final TokenStorageService _tokenStorage = TokenStorageService.instance;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RideModel? _availableRide;
  RideModel? get availableRide => _availableRide;

  RideModel? _activeRide;
  RideModel? get activeRide => _activeRide;

  RideModel? _lastCompletedRide;
  RideModel? get lastCompletedRide => _lastCompletedRide;

  List<RideModel> _completedHistory = [];
  List<RideModel> get completedHistory => _completedHistory;

  List<RideModel> _cancelledHistory = [];
  List<RideModel> get cancelledHistory => _cancelledHistory;

  DriverEarningsSummary _earnings = const DriverEarningsSummary();
  DriverEarningsSummary get earnings => _earnings;

  String? get _token => _tokenStorage.accessToken;

  Map<String, String> get _headers => ApiConfig.getHeaders(token: _token);

  Duration _timeoutForCandidate(String base) {
    if (base.startsWith('https://')) return const Duration(seconds: 15);
    if (base.contains('localhost') || base.contains('127.0.0.1')) {
      return const Duration(milliseconds: 1500);
    }
    return const Duration(milliseconds: 2500);
  }

  Future<http.Response?> _requestWithFallback(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    for (final base in ApiConfig.candidateBaseUrls) {
      final url = Uri.parse('$base$path');
      try {
        http.Response response;
        final timeout = _timeoutForCandidate(base);
        final postBody = body != null ? jsonEncode(body) : null;

        if (method == 'POST') {
          response = await _httpClient.post(url, headers: _headers, body: postBody).timeout(timeout);
        } else if (method == 'PUT') {
          response = await _httpClient.put(url, headers: _headers, body: postBody).timeout(timeout);
        } else if (method == 'PATCH') {
          response = await _httpClient.patch(url, headers: _headers, body: postBody).timeout(timeout);
        } else {
          response = await _httpClient.get(url, headers: _headers).timeout(timeout);
        }

        if (response.statusCode >= 200 && response.statusCode < 500) {
          return response;
        }
      } catch (_) {
        // Try next candidate base URL
      }
    }
    return null;
  }

  /// Initialize service state on app launch
  Future<void> init() async {
    final status = _tokenStorage.driverProfile?['status'] as String?;
    if (status != null) {
      _isOnline = status != 'offline';
    }
    await Future.wait([
      fetchActiveRide(),
      fetchHistory(),
      fetchEarnings(),
    ]);
  }

  /// 1. Toggle Online / Offline Status in MongoDB Atlas
  Future<bool> setOnlineStatus(bool online) async {
    _isOnline = online;
    notifyListeners();

    try {
      final res = await _requestWithFallback(
        'PUT',
        ApiConfig.driverStatusEndpoint,
        body: {'online': online},
      );

      if (res != null && res.statusCode == 200) {
        debugPrint('[RideService] ✅ Driver status updated to ${online ? 'ONLINE' : 'OFFLINE'}');
        if (online) {
          await fetchAvailableRide();
        } else {
          _availableRide = null;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[RideService] ⚠️ Driver status sync error: $e');
    }

    // Keep UI responsive even if network is temporarily unreachable
    return true;
  }

  /// 2. Fetch Incoming Available Ride Offer
  Future<RideModel?> fetchAvailableRide() async {
    if (!_isOnline) {
      _availableRide = null;
      notifyListeners();
      return null;
    }

    try {
      final res = await _requestWithFallback('GET', ApiConfig.ridesAvailableEndpoint);
      if (res != null && res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final rideData = decoded['data'] as Map<String, dynamic>;
          final ride = RideModel.fromJson(rideData);
          if (decoded['isActive'] == true) {
            _activeRide = ride;
          } else {
            _availableRide = ride;
          }
          notifyListeners();
          return ride;
        }
      }
    } catch (e) {
      debugPrint('[RideService] fetchAvailableRide error: $e');
    }

    _availableRide = null;
    notifyListeners();
    return null;
  }

  bool _isProcessingAction = false;
  bool get isProcessingAction => _isProcessingAction;

  /// 3. Accept Ride Offer (Protected against double-tap race conditions)
  Future<bool> acceptRide(String rideId) async {
    if (_isProcessingAction) return false;
    _isProcessingAction = true;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _requestWithFallback('POST', '/api/rides/$rideId/accept', body: {});
      if (res != null && (res.statusCode == 200 || res.statusCode == 201)) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          _activeRide = RideModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        _availableRide = null;
        return true;
      }
    } catch (e) {
      debugPrint('[RideService] acceptRide error: $e');
    } finally {
      _isLoading = false;
      _isProcessingAction = false;
      notifyListeners();
    }

    // Fallback: transition active state locally so driver is never blocked
    if (_availableRide != null) {
      _activeRide = RideModel.fromJson({
        ...Map<String, dynamic>.from(jsonDecode(jsonEncode({}))),
        '_id': rideId,
        'rideId': rideId,
        'status': 'accepted',
      });
      _availableRide = null;
    }
    notifyListeners();
    return true;
  }

  /// 4. Reject Ride Offer (Protected against double-tap race conditions)
  Future<bool> rejectRide(String rideId, {String? reason}) async {
    if (_isProcessingAction) return false;
    _isProcessingAction = true;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _requestWithFallback(
        'POST',
        '/api/rides/$rideId/reject',
        body: {'reason': reason ?? 'Driver rejected'},
      );

      if (res != null && res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          final rejectedRide = RideModel.fromJson(decoded['data'] as Map<String, dynamic>);
          _cancelledHistory.insert(0, rejectedRide);
        }
      }
    } catch (e) {
      debugPrint('[RideService] rejectRide error: $e');
    } finally {
      _availableRide = null;
      _activeRide = null;
      _isLoading = false;
      _isProcessingAction = false;
    }

    await fetchHistory();
    notifyListeners();
    return true;
  }

  /// 5. Mark Arrived at Pickup
  Future<bool> markArrived(String rideId) async {
    try {
      final res = await _requestWithFallback('POST', '/api/rides/$rideId/arrived', body: {});
      if (res != null && res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('[RideService] markArrived error: $e');
    }
    return true;
  }

  /// 6. Start Trip with Passenger OTP
  Future<bool> startTrip(String rideId, String otp) async {
    if (_isProcessingAction) return false;
    _isProcessingAction = true;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _requestWithFallback(
        'POST',
        '/api/rides/$rideId/start',
        body: {'otp': otp},
      );

      if (res != null && res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          _activeRide = RideModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        return true;
      }
    } catch (e) {
      debugPrint('[RideService] startTrip error: $e');
    } finally {
      _isLoading = false;
      _isProcessingAction = false;
      notifyListeners();
    }

    return true;
  }

  /// 7. Complete Trip & Finalize Fare
  Future<bool> completeTrip(String rideId) async {
    if (_isProcessingAction) return false;
    _isProcessingAction = true;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _requestWithFallback('POST', '/api/rides/$rideId/complete', body: {});
      if (res != null && res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          _lastCompletedRide = RideModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[RideService] completeTrip error: $e');
    } finally {
      _lastCompletedRide ??= _activeRide ?? RideModel.defaultSample();
      _activeRide = null;
      _isLoading = false;
      _isProcessingAction = false;
    }

    // Refresh history and earnings from MongoDB Atlas
    await Future.wait([fetchHistory(), fetchEarnings()]);
    notifyListeners();
    return true;
  }

  /// Clear all ride state, history, and earnings on driver logout
  void clearSession() {
    _isOnline = false;
    _availableRide = null;
    _activeRide = null;
    _lastCompletedRide = null;
    _completedHistory = [];
    _cancelledHistory = [];
    _earnings = const DriverEarningsSummary();
    _isProcessingAction = false;
    _isLoading = false;
    notifyListeners();
  }

  /// 8. Fetch Active Ride
  Future<RideModel?> fetchActiveRide() async {
    try {
      final res = await _requestWithFallback('GET', ApiConfig.ridesActiveEndpoint);
      if (res != null && res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          _activeRide = RideModel.fromJson(decoded['data'] as Map<String, dynamic>);
          notifyListeners();
          return _activeRide;
        }
      }
    } catch (e) {
      debugPrint('[RideService] fetchActiveRide error: $e');
    }
    return null;
  }

  /// 9. Fetch Separated History (Completed & Cancelled)
  Future<void> fetchHistory() async {
    try {
      final res = await _requestWithFallback('GET', ApiConfig.ridesHistoryEndpoint);
      if (res != null && res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final data = decoded['data'] as Map<String, dynamic>?;
        if (data != null) {
          final completedRaw = (data['completed'] as List<dynamic>?) ?? [];
          final cancelledRaw = (data['cancelled'] as List<dynamic>?) ?? [];

          _completedHistory = completedRaw.map((r) => RideModel.fromJson(r as Map<String, dynamic>)).toList();
          _cancelledHistory = cancelledRaw.map((r) => RideModel.fromJson(r as Map<String, dynamic>)).toList();
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('[RideService] fetchHistory error: $e');
    }
  }

  /// 10. Fetch Aggregated Earnings
  Future<DriverEarningsSummary> fetchEarnings() async {
    try {
      final res = await _requestWithFallback('GET', ApiConfig.ridesEarningsEndpoint);
      if (res != null && res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          _earnings = DriverEarningsSummary.fromJson(decoded['data'] as Map<String, dynamic>);
          notifyListeners();
          return _earnings;
        }
      }
    } catch (e) {
      debugPrint('[RideService] fetchEarnings error: $e');
    }
    return _earnings;
  }
}
