import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../shared/config/map_config.dart';

/// Outcome of asking for the device position. Callers must branch on this so
/// they can show the right message for each situation.
enum LocationOutcome {
  /// A position was returned.
  success,

  /// The device location service (GPS) is turned off.
  serviceDisabled,

  /// The user has not yet granted permission and has not been asked.
  permissionDenied,

  /// The user permanently denied permission (or cannot be asked again).
  permissionDeniedForever,

  /// Anything else (timeout, unsupported platform, unexpected error).
  error,
}

/// Result of [LocationService.getCurrentPosition] with a reason on failure.
class LocationResult {
  const LocationResult.success(this.position)
      : outcome = LocationOutcome.success,
        message = null;
  const LocationResult.failure(this.outcome, this.message) : position = null;

  final Position? position;
  final LocationOutcome outcome;
  final String? message;

  bool get isSuccess => outcome == LocationOutcome.success;
}

class LocationSearchResult {
  const LocationSearchResult({
    required this.displayName,
    required this.shortName,
    required this.point,
  });

  final String displayName;
  final String shortName;
  final LatLng point;
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Default fallback center (Malang, East Java) used only as a map camera
  /// starting point, never as a saved product location.
  static const LatLng defaultLocation = MapConfig.defaultCenter;

  /// Last time a Nominatim request was started, to respect the 1 req/s limit.
  DateTime? _lastNominatimCall;

  /// In-memory caches. Nominatim requires clients to cache results; repeated
  /// identical queries are not allowed.
  final Map<String, String> _reverseCache = <String, String>{};
  final Map<String, List<LocationSearchResult>> _searchCache =
      <String, List<LocationSearchResult>>{};

  /// Computes distance in kilometers between two coordinates using the
  /// platform implementation from geolocator (meters -> km).
  ///
  /// [Geolocator.distanceBetween] is a pure function, so this is unit-testable
  /// without a device.
  double calculateDistanceKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final meters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return meters / 1000.0;
  }

  /// Formatted distance string (e.g. "1.2 km away", "850 m away").
  String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$meters m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  /// Rounds a coordinate to the configured number of decimals so buyers see
  /// an approximate pickup area rather than an exact doorstep.
  static double roundCoordinate(double value) {
    final factor = math.pow(10, MapConfig.coordinateDecimals).toDouble();
    return (value * factor).round() / factor;
  }

  /// Validates that a latitude/longitude pair is inside legal ranges.
  static bool isValidLatitude(double value) => value >= -90 && value <= 90;
  static bool isValidLongitude(double value) => value >= -180 && value <= 180;

  /// Gets the current device position, reporting *why* it failed.
  Future<LocationResult> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.failure(
          LocationOutcome.serviceDisabled,
          'Turn on your device location (GPS) to detect your position.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const LocationResult.failure(
          LocationOutcome.permissionDenied,
          'Location permission was denied. You can set your location manually.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(
          LocationOutcome.permissionDeniedForever,
          'Location permission is permanently denied. Enable it in settings or set your location manually.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 7),
        ),
      );
      return LocationResult.success(position);
    } catch (e) {
      debugPrint('Geolocator error: $e');
      return const LocationResult.failure(
        LocationOutcome.error,
        'Could not get your position. You can set your location manually.',
      );
    }
  }

  /// Opens the OS app-settings page so a permanently-denied user can recover.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Opens the OS location (GPS) settings page.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Ensures at least 1 second passes between Nominatim calls.
  Future<void> _respectNominatimRateLimit() async {
    final now = DateTime.now();
    if (_lastNominatimCall != null) {
      final elapsed = now.difference(_lastNominatimCall!);
      if (elapsed < const Duration(seconds: 1)) {
        await Future<void>.delayed(const Duration(seconds: 1) - elapsed);
      }
    }
    _lastNominatimCall = DateTime.now();
  }

  /// Reverse geocodes a point using OpenStreetMap Nominatim.
  ///
  /// Results are cached by rounded coordinates and calls are throttled to
  /// respect Nominatim's 1 request/second limit.
  Future<String> reverseGeocode(LatLng point) async {
    final key = '${point.latitude.toStringAsFixed(4)},'
        '${point.longitude.toStringAsFixed(4)}';
    final cached = _reverseCache[key];
    if (cached != null) return cached;

    try {
      await _respectNominatimRateLimit();
      final uri = Uri.parse(
        '${MapConfig.nominatimBaseUrl}/reverse?format=jsonv2'
        '&lat=${point.latitude}&lon=${point.longitude}&zoom=16&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': MapConfig.nominatimUserAgent,
          'Accept-Language': 'id,en',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final address = data['address'] as Map<String, dynamic>?;
          if (address != null) {
            final suburb = address['suburb'] ??
                address['village'] ??
                address['neighbourhood'] ??
                address['residential'];
            final city = address['city'] ??
                address['town'] ??
                address['county'] ??
                address['municipality'];

            final result = (suburb != null && city != null)
                ? '$suburb, $city'
                : (city != null ? '$city' : null);
            if (result != null) {
              _reverseCache[key] = result;
              return result;
            }
          }
          final displayName = data['display_name'] as String?;
          if (displayName != null && displayName.isNotEmpty) {
            final parts = displayName.split(',');
            final result = parts.length > 2
                ? '${parts[0].trim()}, ${parts[1].trim()}'
                : displayName;
            _reverseCache[key] = result;
            return result;
          }
        }
      }
    } catch (e) {
      debugPrint('OSM Reverse geocoding failed: $e');
    }

    // Fall back to a coordinate label but do NOT cache it, so a later attempt
    // can still succeed once the service is reachable.
    return '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
  }

  /// Searches places via OpenStreetMap Nominatim.
  ///
  /// Only ever called from an explicit user action (a Search button), never
  /// from typing, because Nominatim forbids autocomplete. Results are cached
  /// and calls are throttled to 1 request/second.
  Future<List<LocationSearchResult>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final cached = _searchCache[trimmed.toLowerCase()];
    if (cached != null) return cached;

    try {
      await _respectNominatimRateLimit();
      final uri = Uri.parse(
        '${MapConfig.nominatimBaseUrl}/search?format=jsonv2'
        '&q=${Uri.encodeComponent(trimmed)}&limit=5&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': MapConfig.nominatimUserAgent,
          'Accept-Language': 'id,en',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body);
        if (list is List) {
          final results = list.map((item) {
            final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
            final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
            final displayName = item['display_name']?.toString() ?? '';
            final parts = displayName.split(',');
            final short = parts.length > 2
                ? '${parts[0].trim()}, ${parts[1].trim()}'
                : displayName;

            return LocationSearchResult(
              displayName: displayName,
              shortName: short,
              point: LatLng(lat, lon),
            );
          }).where((res) => res.point.latitude != 0.0).toList();
          _searchCache[trimmed.toLowerCase()] = results;
          return results;
        }
      }
    } catch (e) {
      debugPrint('OSM search places error: $e');
    }
    return const [];
  }
}
