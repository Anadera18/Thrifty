import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/config/map_config.dart';
import '../../../../shared/widgets/map_clusterer.dart';
import '../../../product_detail/presentation/screens/product_detail.dart';

const Color _darkTeal = Color(0xFF0E3436);
const Color _green = Color(0xFF14532D);
const Color _bg = Color(0xFFFBF9FF);
const Color _ink = Color(0xFF111827);
const Color _muted = Color(0xFF5B6270);

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({
    super.key,
    required this.products,
    this.userLocation,
  });

  final List<ProductModel> products;
  final LatLng? userLocation;

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  late final MapController _mapController;
  ProductModel? _selectedProduct;
  late LatLng _center;
  bool _didFitBounds = false;

  /// Products that can actually be drawn (they have coordinates).
  List<ProductModel> get _mappableProducts => widget.products
      .where((p) => p.latitude != null && p.longitude != null)
      .toList();

  /// Points used to frame the initial view: every mappable product, plus the
  /// buyer's position when it is known.
  List<LatLng> get _fitPoints {
    final points = _mappableProducts
        .map((p) => LatLng(p.latitude!, p.longitude!))
        .toList();
    if (widget.userLocation != null) points.add(widget.userLocation!);
    return points;
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _center = widget.userLocation ??
        (_mappableProducts.isNotEmpty
            ? LatLng(
                _mappableProducts.first.latitude!,
                _mappableProducts.first.longitude!,
              )
            : LocationService.defaultLocation);
  }

  @override
  void didUpdateWidget(covariant NearbyMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLocation != widget.userLocation &&
        widget.userLocation != null) {
      _center = widget.userLocation!;
    }
  }

  /// Fits all pins in view once, after the first frame, when there is more
  /// than one point to show. This is better than a fixed zoom because pins are
  /// not always close to the buyer.
  void _fitToPointsOnce() {
    if (_didFitBounds) return;
    _didFitBounds = true;
    final points = _fitPoints;
    if (points.length < 2) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.fromLTRB(48, 48, 48, 120),
          ),
        );
      } catch (_) {
        // If fitting fails (for example a single, degenerate point), keep the
        // default center. Not worth interrupting the user for.
      }
    });
  }

  /// Builds one marker per cluster group: a price pin for single products and
  /// a numbered bubble for groups. Takes the camera explicitly because it must
  /// only be called from inside the map's subtree, where the camera exists.
  List<Marker> _buildProductMarkers(
    List<ProductModel> products,
    MapCamera camera,
  ) {
    if (products.isEmpty) return const [];
    // Before the first layout the camera size is a placeholder; projecting
    // then would put every pin at the origin, so skip until it is real.
    if (camera.nonRotatedSize == MapCamera.kImpossibleSize) {
      return const [];
    }
    if (camera.nonRotatedSize.isEmpty) return const [];

    final entries = products
        .map((p) => (LatLng(p.latitude!, p.longitude!), p))
        .toList();

    final groups = MapClusterer<ProductModel>(camera: camera).cluster(entries);

    return groups.map((group) {
      if (!group.isCluster) {
        final product = group.items.first;
        final point = group.centroid;
        final isSelected = _selectedProduct?.id == product.id;
        return Marker(
          point: point,
          width: isSelected ? 80 : 54,
          height: isSelected ? 48 : 34,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedProduct = product);
              _mapController.move(point, camera.zoom);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? _green : _darkTeal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Center(
                child: Text(
                  product.formattedPrice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSelected ? 10 : 8.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final count = group.count;
      final diameter = count < 10
          ? 42.0
          : count < 100
              ? 48.0
              : 54.0;
      return Marker(
        point: group.centroid,
        width: diameter,
        height: diameter,
        child: GestureDetector(
          onTap: () => _showClusterSheet(group.items),
          child: Container(
            decoration: BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Text(
                '$count',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: count < 100 ? 12 : 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Shows the products grouped inside a cluster bubble so every one is
  /// reachable, even when two listings share the same coordinates and can
  /// never be split by zooming.
  void _showClusterSheet(List<ProductModel> products) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
                child: Row(
                  children: [
                    const Icon(Icons.layers_rounded, color: _darkTeal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${products.length} listings here',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _mapController.move(
                          LatLng(
                            products.first.latitude!,
                            products.first.longitude!,
                          ),
                          (_mapController.camera.zoom + 2).clamp(3.0, 18.0),
                        );
                      },
                      child: Text(
                        'Zoom in',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _darkTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFE5E3EF)),
                  itemBuilder: (_, i) {
                    final product = products[i];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 46,
                          height: 46,
                          color: const Color(0xFFD9E8EA),
                          child: product.imageUrls.isNotEmpty
                              ? Image.network(
                                  product.imageUrls.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.checkroom_rounded,
                                    color: _darkTeal,
                                  ),
                                )
                              : const Icon(Icons.checkroom_rounded,
                                  color: _darkTeal),
                        ),
                      ),
                      title: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      subtitle: Text(
                        product.formattedPrice,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _green,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: _muted),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              product: ProductDetailsData.fromModel(product),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mappableProducts = _mappableProducts;
    _fitToPointsOnce();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          'Nearby Preloved Map',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: _darkTeal),
            tooltip: 'My Location',
            onPressed: () {
              final loc = widget.userLocation;
              if (loc != null) {
                _mapController.move(loc, 14.0);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Your location is not set. Set it from the Home screen.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.0,
              onTap: (_, __) {
                if (_selectedProduct != null) {
                  setState(() => _selectedProduct = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: MapConfig.osmTileUrl,
                userAgentPackageName: MapConfig.userAgentPackageName,
              ),
              // User position marker, drawn below the product markers so a
              // cluster bubble is never hidden or blocked by it.
              if (widget.userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.userLocation!,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              // Product markers, clustered by screen distance so overlapping
              // pins merge into numbered bubbles as the user zooms out.
              // MapCamera.of is only valid inside the map's subtree, which is
              // why this is a builder rather than a precomputed list.
              Builder(
                builder: (context) {
                  final camera = MapCamera.of(context);
                  return MarkerLayer(
                    markers: _buildProductMarkers(mappableProducts, camera),
                  );
                },
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          // Top pill counter
          Positioned(
            top: 14,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: _green),
                  const SizedBox(width: 4),
                  Text(
                    '${mappableProducts.length} items on map',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (mappableProducts.isEmpty)
            Positioned(
              top: 60,
              left: 18,
              right: 18,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_outlined,
                        size: 18, color: _muted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No nearby listings have a pickup location yet. '
                        'Products appear here once a seller sets one.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Bottom product preview card
          if (_selectedProduct != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        product: ProductDetailsData.fromModel(_selectedProduct!),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 64,
                          height: 64,
                          color: const Color(0xFFD9E8EA),
                          child: _selectedProduct!.imageUrls.isNotEmpty
                              ? Image.network(
                                  _selectedProduct!.imageUrls.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.checkroom_rounded,
                                    color: _darkTeal,
                                  ),
                                )
                              : const Icon(Icons.checkroom_rounded, color: _darkTeal),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedProduct!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedProduct!.formattedPrice,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.place_outlined, size: 12, color: _muted),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    '${_selectedProduct!.pickupLocation} • ${_selectedProduct!.distance}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: _muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _darkTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
