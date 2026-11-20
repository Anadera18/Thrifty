import 'dart:ui' show Offset;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// One group of points that are close enough on screen to be drawn as a
/// single cluster bubble.
class ClusterGroup<T> {
  ClusterGroup({
    required this.items,
    required this.centroid,
    required this.screenOffset,
  });

  /// The items in this group. A group with one item is drawn as a normal pin.
  final List<T> items;

  /// The geographic centre of the group's items (used to place the bubble).
  final LatLng centroid;

  /// The screen position of [centroid] at the time of clustering.
  final Offset screenOffset;

  bool get isCluster => items.length > 1;
  int get count => items.length;
}

/// A tiny, dependency-free screen-space clustering helper.
///
/// It does not use any external clustering package: it projects each point with
/// the map's own [MapCamera.latLngToScreenOffset], then greedily groups points
/// whose screen distance is within [radiusPixels]. This keeps clustering tied
/// to the real tile geometry and needs no extra package.
class MapClusterer<T> {
  const MapClusterer({
    required this.camera,
    this.radiusPixels = 48,
  });

  final MapCamera camera;

  /// Two points closer than this many pixels on screen are grouped together.
  final double radiusPixels;

  /// Groups [entries] (a point paired with its value) into clusters.
  ///
  /// This is O(n * k) where k is the number of groups, which is fine for the
  /// prototype's data sizes. Points that are off-screen are still returned so
  /// callers can decide what to do; grouping is purely by screen distance.
  List<ClusterGroup<T>> cluster(List<(LatLng, T)> entries) {
    final groups = <ClusterGroup<T>>[];

    for (final entry in entries) {
      final point = entry.$1;
      final offset = camera.latLngToScreenOffset(point);

      ClusterGroup<T>? nearest;
      var nearestDistance = double.infinity;
      for (final group in groups) {
        final distance = (group.screenOffset - offset).distance;
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearest = group;
        }
      }

      if (nearest != null && nearestDistance <= radiusPixels) {
        final items = [...nearest.items, entry.$2];
        final centroid = _centroid(items, entry, nearest, point);
        groups[groups.indexOf(nearest)] = ClusterGroup<T>(
          items: items,
          centroid: centroid,
          screenOffset: camera.latLngToScreenOffset(centroid),
        );
      } else {
        groups.add(
          ClusterGroup<T>(
            items: [entry.$2],
            centroid: point,
            screenOffset: offset,
          ),
        );
      }
    }

    return groups;
  }

  /// Recomputes the centre of a group. We keep the running screen position and
  /// blend the new point's position in, which is cheap and stable enough for a
  /// visual bubble. The exact mean of all points would need every point kept,
  /// so we approximate with the previous centroid weighted by group size.
  LatLng _centroid(
    List<T> items,
    (LatLng, T) entry,
    ClusterGroup<T> previous,
    LatLng newPoint,
  ) {
    final n = items.length;
    final lat =
        (previous.centroid.latitude * (n - 1) + newPoint.latitude) / n;
    final lng =
        (previous.centroid.longitude * (n - 1) + newPoint.longitude) / n;
    return LatLng(lat, lng);
  }
}
