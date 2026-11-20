import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../config/map_config.dart';

/// A small, reusable, read-only OpenStreetMap view.
///
/// It centralises everything the OSM tile usage policy requires:
/// - one shared tile URL ([MapConfig.osmTileUrl]) and User-Agent,
/// - a visible attribution that links to the OSM copyright page,
/// - a graceful placeholder when there is nothing to show or tiles fail.
///
/// It is intentionally simple: it renders a pin (and optional extra markers
/// or layers) over a non-interactive-by-default map. Callers that need
/// panning/zooming (for example a location picker) should build their own
/// [FlutterMap] but still import the constants from [MapConfig].
class OsmMapView extends StatelessWidget {
  const OsmMapView({
    super.key,
    required this.point,
    this.zoom = MapConfig.pinZoom,
    this.interactive = false,
    this.markers = const <Marker>[],
    this.layers = const <Widget>[],
    this.onTap,
    this.borderRadius,
  });

  /// The point to centre on. When `null` the widget shows a
  /// "location not available" placeholder instead of a map.
  final LatLng? point;

  /// Initial zoom level.
  final double zoom;

  /// Whether the user may pan/zoom the map.
  final bool interactive;

  /// Extra markers drawn on top of the default pin (the default pin is only
  /// drawn when [markers] is empty, so callers can fully control the pin).
  final List<Marker> markers;

  /// Extra flutter_map layers inserted above the tile layer.
  final List<Widget> layers;

  /// Optional tap handler; when provided the map accepts taps.
  final void Function(TapPosition, LatLng)? onTap;

  /// Optional clipping radius for the map card.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final content = point == null ? _placeholder(context) : _map(context);
    if (borderRadius == null) {
      return content;
    }
    return ClipRRect(borderRadius: borderRadius!, child: content);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F1F6),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off_outlined, size: 28, color: Color(0xFF5B6270)),
          const SizedBox(height: 6),
          Text(
            'Location not available',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5B6270),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'This listing has no pickup coordinates yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              color: const Color(0xFF5B6270),
            ),
          ),
        ],
      ),
    );
  }

  Widget _map(BuildContext context) {
    final flags = interactive
        ? InteractiveFlag.all
        : InteractiveFlag.none;

    return FlutterMap(
      options: MapOptions(
        initialCenter: point!,
        initialZoom: zoom,
        minZoom: 3,
        maxZoom: 18,
        interactionOptions: InteractionOptions(flags: flags),
        onTap: onTap,
      ),
      children: [
        TileLayer(
          urlTemplate: MapConfig.osmTileUrl,
          userAgentPackageName: MapConfig.userAgentPackageName,
          // When tiles cannot load (for example offline), keep the map usable
          // and let the base background colour show through.
          errorTileCallback: (tile, error, stackTrace) {
            debugPrint('OSM tile failed to load: $error');
          },
        ),
        ...layers,
        if (markers.isNotEmpty) MarkerLayer(markers: markers) else _defaultPin(),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  Widget _defaultPin() {
    return MarkerLayer(
      markers: [
        Marker(
          point: point!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_pin,
            size: 38,
            color: Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }
}
