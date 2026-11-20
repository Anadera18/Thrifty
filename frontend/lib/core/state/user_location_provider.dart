import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';

/// The buyer's current position and how it was obtained.
class UserLocationState {
  const UserLocationState({
    this.point,
    this.label = 'Location not set',
    this.isLocating = false,
    this.outcome,
    this.message,
  });

  /// The buyer's position, or `null` when it is not known.
  final LatLng? point;

  /// A short human-readable label ("Lowokwaru, Malang" or "Location not set").
  final String label;

  /// Whether a GPS lookup is currently in flight.
  final bool isLocating;

  /// Why the last GPS lookup failed, if it did.
  final LocationOutcome? outcome;

  /// A short message explaining a failure, for a snackbar.
  final String? message;

  bool get hasLocation => point != null;

  UserLocationState copyWith({
    LatLng? point,
    String? label,
    bool? isLocating,
    LocationOutcome? outcome,
    String? message,
    bool clearPoint = false,
    bool clearMessage = false,
  }) {
    return UserLocationState(
      point: clearPoint ? null : (point ?? this.point),
      label: label ?? this.label,
      isLocating: isLocating ?? this.isLocating,
      outcome: outcome ?? this.outcome,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

/// Holds the buyer's location for the whole session, in memory only.
///
/// It is deliberately NOT persisted: the app never stores or sends the
/// buyer's position, and it is re-detected (or re-entered) on each launch.
class UserLocationNotifier extends Notifier<UserLocationState> {
  @override
  UserLocationState build() => const UserLocationState();

  /// Asks the device for the current position.
  ///
  /// On failure the state keeps no point and carries the reason, so the UI
  /// can show a helpful message and offer [setManual].
  Future<void> detect() async {
    state = state.copyWith(isLocating: true, clearMessage: true);
    final result = await LocationService.instance.getCurrentPosition();

    if (result.isSuccess && result.position != null) {
      final pos = result.position!;
      final point = LatLng(pos.latitude, pos.longitude);
      final label = await LocationService.instance.reverseGeocode(point);
      state = state.copyWith(
        point: point,
        label: label,
        isLocating: false,
        outcome: LocationOutcome.success,
        clearMessage: true,
      );
    } else {
      state = state.copyWith(
        isLocating: false,
        outcome: result.outcome,
        message: result.message,
        clearPoint: true,
        label: 'Location not set',
      );
    }
  }

  /// Sets the position manually (the fallback when GPS is denied or off).
  void setManual(LatLng point, String label) {
    state = state.copyWith(
      point: point,
      label: label,
      isLocating: false,
      outcome: LocationOutcome.success,
      clearMessage: true,
    );
  }

  /// Clears the message after the UI has shown it once.
  void clearMessage() {
    if (state.message != null) {
      state = state.copyWith(clearMessage: true);
    }
  }
}

/// The single shared buyer location used by Home and the nearby map.
final userLocationProvider =
    NotifierProvider<UserLocationNotifier, UserLocationState>(
  UserLocationNotifier.new,
);
