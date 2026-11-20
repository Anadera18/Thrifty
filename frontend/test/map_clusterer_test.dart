import 'dart:ui' show Size;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:thrifty/shared/widgets/map_clusterer.dart';

/// Builds a camera centred on [center] at [zoom] with a real (non-placeholder)
/// size, which is what the clusterer needs to project points.
MapCamera _camera({LatLng? center, double zoom = 13, double size = 400}) {
  return MapCamera(
    crs: const Epsg3857(),
    center: center ?? const LatLng(-7.9666, 112.6326),
    zoom: zoom,
    rotation: 0,
    nonRotatedSize: Size(size, size),
  );
}

void main() {
  group('MapClusterer', () {
    test('groups points that are on top of each other into one cluster', () {
      final camera = _camera();
      final entries = <(LatLng, String)>[
        (const LatLng(-7.9666, 112.6326), 'a'),
        (const LatLng(-7.96660, 112.63260), 'b'),
        (const LatLng(-7.96661, 112.63261), 'c'),
      ];
      final groups = MapClusterer<String>(camera: camera).cluster(entries);
      expect(groups.length, 1);
      expect(groups.first.isCluster, isTrue);
      expect(groups.first.count, 3);
      expect(groups.first.items, containsAll(<String>['a', 'b', 'c']));
    });

    test('keeps far-apart points as single-item groups', () {
      final camera = _camera(zoom: 13);
      // Jakarta and Surabaya are hundreds of kilometres apart and cannot be
      // within 48 screen pixels at any reasonable prototype zoom.
      final entries = <(LatLng, String)>[
        (const LatLng(-6.2088, 106.8456), 'jakarta'),
        (const LatLng(-7.2575, 112.7521), 'surabaya'),
      ];
      final groups = MapClusterer<String>(camera: camera).cluster(entries);
      expect(groups.length, 2);
      expect(groups.every((g) => !g.isCluster), isTrue);
    });

    test('splits a cluster as the map zooms in', () {
      // Two points about 200 m apart.
      const a = LatLng(-7.9666, 112.6326);
      const b = LatLng(-7.9648, 112.6326);

      final outGroups = MapClusterer<String>(
        camera: _camera(zoom: 9),
      ).cluster([(a, 'a'), (b, 'b')]);

      final inGroups = MapClusterer<String>(
        camera: _camera(zoom: 18),
      ).cluster([(a, 'a'), (b, 'b')]);

      // Zoomed far out they merge; zoomed in they separate. This is the core
      // behaviour of clustering.
      expect(outGroups.length, 1);
      expect(inGroups.length, 2);
    });

    test('an empty input produces no clusters', () {
      final groups =
          MapClusterer<String>(camera: _camera()).cluster(const []);
      expect(groups, isEmpty);
    });

    test('respects the configured radius', () {
      const a = LatLng(-7.9666, 112.6326);
      const b = LatLng(-7.9652, 112.6326);
      final entries = <(LatLng, String)>[(a, 'a'), (b, 'b')];

      final tight = MapClusterer<String>(
        camera: _camera(zoom: 15),
        radiusPixels: 1,
      ).cluster(entries);
      final loose = MapClusterer<String>(
        camera: _camera(zoom: 15),
        radiusPixels: 400,
      ).cluster(entries);

      expect(tight.length, 2);
      expect(loose.length, 1);
    });
  });
}
