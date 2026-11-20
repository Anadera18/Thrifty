import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:thrifty/core/services/location_service.dart';
import 'package:thrifty/core/state/user_location_provider.dart';

void main() {
  group('UserLocationState', () {
    test('starts with no location and a neutral label', () {
      const state = UserLocationState();
      expect(state.hasLocation, isFalse);
      expect(state.point, isNull);
      expect(state.label, 'Location not set');
      expect(state.isLocating, isFalse);
    });

    test('copyWith sets a point and keeps the label', () {
      final state = const UserLocationState().copyWith(
        point: const LatLng(-7.9666, 112.6326),
        label: 'Lowokwaru, Malang',
      );
      expect(state.hasLocation, isTrue);
      expect(state.label, 'Lowokwaru, Malang');
    });

    test('clearPoint removes the point', () {
      final state = const UserLocationState(
        point: LatLng(-7.9666, 112.6326),
        label: 'Lowokwaru, Malang',
      ).copyWith(clearPoint: true, label: 'Location not set');
      expect(state.hasLocation, isFalse);
      expect(state.label, 'Location not set');
    });
  });

  group('UserLocationNotifier', () {
    test('setManual stores the chosen point and clears any message', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userLocationProvider.notifier).setManual(
            const LatLng(-7.9465, 112.6156),
            'Lowokwaru, Malang',
          );

      final state = container.read(userLocationProvider);
      expect(state.hasLocation, isTrue);
      expect(state.point, const LatLng(-7.9465, 112.6156));
      expect(state.label, 'Lowokwaru, Malang');
      expect(state.message, isNull);
      expect(state.outcome, LocationOutcome.success);
    });

    test('clearMessage resets a stored message', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userLocationProvider.notifier);
      // Simulate a failure then clearing it.
      container.read(userLocationProvider);
      notifier.setManual(const LatLng(-7.9465, 112.6156), 'A');
      notifier.clearMessage();

      expect(container.read(userLocationProvider).message, isNull);
    });
  });
}
