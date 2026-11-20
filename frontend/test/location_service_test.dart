import 'package:flutter_test/flutter_test.dart';
import 'package:thrifty/core/services/location_service.dart';

void main() {
  group('LocationService distance', () {
    // Jakarta (-6.2088, 106.8456) to Surabaya (-7.2575, 112.7521).
    // Great-circle distance is commonly quoted around 660-670 km.
    test('Jakarta to Surabaya is in a plausible range', () {
      final km = LocationService.instance.calculateDistanceKm(
        -6.2088,
        106.8456,
        -7.2575,
        112.7521,
      );
      expect(km, greaterThan(600));
      expect(km, lessThan(700));
    });

    // Malang (-7.9666, 112.6326) to Surabaya (-7.2575, 112.7521) is roughly
    // 80 km by great circle.
    test('Malang to Surabaya is in a plausible range', () {
      final km = LocationService.instance.calculateDistanceKm(
        -7.9666,
        112.6326,
        -7.2575,
        112.7521,
      );
      expect(km, greaterThan(60));
      expect(km, lessThan(100));
    });

    test('distance to the same point is zero', () {
      final km = LocationService.instance.calculateDistanceKm(
        -7.9666,
        112.6326,
        -7.9666,
        112.6326,
      );
      expect(km, 0);
    });

    test('distance is symmetric', () {
      const aLat = -6.2088, aLon = 106.8456;
      const bLat = -7.2575, bLon = 112.7521;
      final forward =
          LocationService.instance.calculateDistanceKm(aLat, aLon, bLat, bLon);
      final backward =
          LocationService.instance.calculateDistanceKm(bLat, bLon, aLat, aLon);
      expect(forward, closeTo(backward, 0.001));
    });
  });

  group('LocationService.formatDistance', () {
    test('under 1 km is shown in metres', () {
      expect(LocationService.instance.formatDistance(0.85), '850 m away');
    });

    test('1 km or more is shown with one decimal in km', () {
      expect(LocationService.instance.formatDistance(1.24), '1.2 km away');
      expect(LocationService.instance.formatDistance(12.0), '12.0 km away');
    });
  });

  group('LocationService.roundCoordinate', () {
    test('rounds to 3 decimals so only an approximate area is stored', () {
      expect(LocationService.roundCoordinate(-7.946512), -7.947);
      expect(LocationService.roundCoordinate(112.615599), 112.616);
    });

    test('leaves already-rounded values unchanged', () {
      expect(LocationService.roundCoordinate(-7.946), -7.946);
    });
  });

  group('LocationService coordinate validation', () {
    test('accepts legal ranges', () {
      expect(LocationService.isValidLatitude(-7.9666), isTrue);
      expect(LocationService.isValidLongitude(112.6326), isTrue);
    });

    test('rejects out-of-range values', () {
      expect(LocationService.isValidLatitude(91), isFalse);
      expect(LocationService.isValidLongitude(-181), isFalse);
    });
  });
}