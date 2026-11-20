import 'package:latlong2/latlong.dart';

/// Single source of truth for every map/tile/geocoding constant.
///
/// The OpenStreetMap tile URL lives **only here** so the provider can be
/// switched (for example to a paid or self-hosted service before a real
/// launch) without searching the codebase for hardcoded copies.
///
/// Policy reminders (see docs/MAPS.md):
/// - The OSM public tile server is donated infrastructure and is *not* for
///   heavy traffic; it forbids bulk downloading/offline prefetching.
/// - A valid, identifying User-Agent is required on native platforms.
///   Browsers set their own User-Agent on the web.
/// - Attribution "© OpenStreetMap contributors" must stay visible.
class MapConfig {
  const MapConfig._();

  /// The public OSM raster tile endpoint.
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Visible attribution required by the OSM tile usage policy.
  static const String osmAttribution = '© OpenStreetMap contributors';

  /// Link required by the OSM attribution guidelines.
  static const String osmCopyrightUrl =
      'https://www.openstreetmap.org/copyright';

  /// Identifying User-Agent used on native platforms. Generic or library
  /// default User-Agents may be blocked by OSM. Must match the Android
  /// applicationId in android/app/build.gradle.kts.
  static const String userAgentPackageName = 'com.thrifty.thrifty';

  /// Base URL for the OpenStreetMap Nominatim geocoding service.
  ///
  /// Nominatim allows at most 1 request per second, requires an identifying
  /// User-Agent (or Referer on the web), forbids autocomplete, and requires
  /// caching of results. Keep all access to this service behind
  /// [LocationService].
  static const String nominatimBaseUrl =
      'https://nominatim.openstreetmap.org';

  /// Nominatim requires a describing User-Agent on native platforms.
  /// Browsers send their own Referer header, which Nominatim also accepts.
  static const String nominatimUserAgent =
      'Thrifty/1.0 ($userAgentPackageName)';

  /// Sensible default map center (Malang, East Java) used only as a camera
  /// starting point when the user's real position is unknown. It is never
  /// saved as a product location.
  static const LatLng defaultCenter = LatLng(-7.9666, 112.6326);

  /// A reasonable default zoom for a single pickup pin.
  static const double pinZoom = 15.0;

  /// Zoom used when showing a buyer's own position on the nearby map.
  static const double userZoom = 13.0;

  /// Coordinates are stored rounded to 3 decimals (~110 m) so buyers see an
  /// approximate pickup area rather than an exact doorstep.
  static const int coordinateDecimals = 3;
}
