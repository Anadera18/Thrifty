import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/location_service.dart';
import '../config/map_config.dart';

const Color _darkTeal = Color(0xFF0E3436);
const Color _green = Color(0xFF14532D);
const Color _bg = Color(0xFFFBF9FF);
const Color _ink = Color(0xFF111827);
const Color _muted = Color(0xFF5B6270);
const Color _line = Color(0xFFE5E3EF);

class LocationPickerResult {
  const LocationPickerResult({
    required this.address,
    required this.point,
  });

  final String address;
  final LatLng point;
}

class OsmLocationPickerSheet extends StatefulWidget {
  const OsmLocationPickerSheet({
    super.key,
    this.initialPoint,
    this.initialAddress,
  });

  final LatLng? initialPoint;
  final String? initialAddress;

  static Future<LocationPickerResult?> show(
    BuildContext context, {
    LatLng? initialPoint,
    String? initialAddress,
  }) {
    return showModalBottomSheet<LocationPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OsmLocationPickerSheet(
        initialPoint: initialPoint,
        initialAddress: initialAddress,
      ),
    );
  }

  @override
  State<OsmLocationPickerSheet> createState() => _OsmLocationPickerSheetState();
}

class _OsmLocationPickerSheetState extends State<OsmLocationPickerSheet> {
  late final MapController _mapController;
  late LatLng _selectedPoint;
  String _addressText = 'Locating pickup spot...';
  bool _isLoadingAddress = false;
  bool _isLocatingGps = false;
  bool _addressLabelsAreStale = false;

  final TextEditingController _searchController = TextEditingController();
  List<LocationSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _searchAttempted = false;
  bool _searchFailed = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPoint = widget.initialPoint ?? LocationService.defaultLocation;
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _addressText = widget.initialAddress!;
    } else {
      // One reverse-geocode on open is user-triggered (they opened the picker)
      // and well within the Nominatim rate limit.
      _fetchAddress(_selectedPoint);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddress(LatLng point) async {
    setState(() => _isLoadingAddress = true);
    final addr = await LocationService.instance.reverseGeocode(point);
    if (!mounted) return;
    setState(() {
      _addressText = addr;
      _isLoadingAddress = false;
    });
  }

  /// Panning only moves the pin. It must NOT reverse-geocode on every drag:
  /// Nominatim forbids systematic/grid reverse queries and limits clients to
  /// 1 request/second. We only show the raw coordinates while moving and let
  /// the user request a readable address with an explicit button, or fetch it
  /// once when they confirm.
  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    final moved = camera.center;
    if (moved.latitude == _selectedPoint.latitude &&
        moved.longitude == _selectedPoint.longitude) {
      return;
    }
    setState(() {
      _selectedPoint = moved;
      _addressLabelsAreStale = true;
    });
  }

  Future<void> _moveToCurrentGps() async {
    setState(() => _isLocatingGps = true);
    final result = await LocationService.instance.getCurrentPosition();
    if (!mounted) return;
    setState(() => _isLocatingGps = false);

    if (result.isSuccess && result.position != null) {
      final pos = result.position!;
      final point = LatLng(pos.latitude, pos.longitude);
      _selectedPoint = point;
      _mapController.move(point, 16.0);
      _fetchAddress(point);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ??
                'Could not access current location. Please pick on the map.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchAttempted = false;
        _searchFailed = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _searchAttempted = true;
      _searchFailed = false;
    });
    final results = await LocationService.instance.searchPlaces(query);
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isSearching = false;
      // searchPlaces swallows network errors and returns an empty list; treat
      // an empty list as "no results found" rather than an error to avoid
      // claiming a failure we cannot confirm.
      _searchFailed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height * 0.85;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Pickup / Meetup Point',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Drag the map or search to place a safe meetup area',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: _muted),
                ),
              ],
            ),
          ),
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _ink),
              decoration: InputDecoration(
                hintText: 'Search a place, then press Enter/Search...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted),
                prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 20),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _darkTeal,
                          ),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _searchAttempted = false;
                                _searchFailed = false;
                              });
                            },
                          )
                        : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _darkTeal, width: 1.5),
                ),
              ),
            ),
          ),
          // Search results panel: loading, no results, or the list.
          if (_isSearching)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _darkTeal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Searching...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            )
          else if (_searchAttempted &&
              _searchResults.isEmpty &&
              !_searchFailed)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_off_rounded, size: 18, color: _muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No places found. Try a different name or district.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: _muted,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: _line),
                itemBuilder: (context, i) {
                  final item = _searchResults[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, color: _darkTeal, size: 20),
                    title: Text(
                      item.shortName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    subtitle: Text(
                      item.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _muted),
                    ),
                    onTap: () {
                      _selectedPoint = item.point;
                      _mapController.move(item.point, 16.0);
                      _addressText = item.shortName;
                      setState(() {
                        _searchResults = [];
                        _searchAttempted = false;
                        _searchFailed = false;
                      });
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          // Map area
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPoint,
                    initialZoom: 15.0,
                    minZoom: 4.0,
                    maxZoom: 18.0,
                    onPositionChanged: _onPositionChanged,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapConfig.osmTileUrl,
                      userAgentPackageName: MapConfig.userAgentPackageName,
                    ),
                    // Safe zone radius indicator circle around target
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _selectedPoint,
                          radius: 35,
                          useRadiusInMeter: false,
                          color: _green.withValues(alpha: 0.15),
                          borderColor: _green,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
                // Center Pin Marker
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _darkTeal,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 8),
                            ],
                          ),
                          child: Text(
                            'Meetup Area',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.location_pin,
                          size: 42,
                          color: Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  ),
                ),
                // My Location Button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    onPressed: _isLocatingGps ? null : _moveToCurrentGps,
                    backgroundColor: Colors.white,
                    foregroundColor: _darkTeal,
                    elevation: 4,
                    child: _isLocatingGps
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _darkTeal),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),
          // Bottom selection bar
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _line)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place_rounded, color: _green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isLoadingAddress
                              ? 'Updating address...'
                              : _addressLabelsAreStale
                                  ? '${_selectedPoint.latitude.toStringAsFixed(4)}, '
                                      '${_selectedPoint.longitude.toStringAsFixed(4)}'
                                  : _addressText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ),
                      if (_addressLabelsAreStale)
                        TextButton.icon(
                          onPressed: _isLoadingAddress
                              ? null
                              : () async {
                                  await _fetchAddress(_selectedPoint);
                                  if (!mounted) return;
                                  setState(() => _addressLabelsAreStale = false);
                                },
                          icon: const Icon(Icons.search_rounded, size: 16),
                          label: Text(
                            'Describe',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () async {
                        // Round to the configured precision so buyers only see
                        // an approximate pickup area (~100 m), never a doorstep.
                        final rounded = LatLng(
                          LocationService.roundCoordinate(_selectedPoint.latitude),
                          LocationService.roundCoordinate(_selectedPoint.longitude),
                        );
                        Navigator.of(context).pop(
                          LocationPickerResult(
                            address: _addressText,
                            point: rounded,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _darkTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Confirm Meetup Location',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
