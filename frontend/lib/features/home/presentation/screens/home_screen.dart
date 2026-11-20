import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_state_providers.dart';
import '../../../auth/presentation/widgets/seller_only_gate.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../my_listings/presentation/screens/my_listings_screen.dart';
import '../../../add_product/presentation/screens/add_product_screen.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../product_detail/presentation/screens/product_detail.dart';
import '../../../saved_items/presentation/screens/saved_items_screen.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/services/supabase_product_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/state/user_location_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/widgets/osm_location_picker_sheet.dart';
import 'filter_screen.dart';
import 'nearby_map_screen.dart';

const _background = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _green = Color(0xFF14532D);
const _darkTeal = Color(0xFF0E3436);
const _cyanSoft = Color(0xFFCFF5FA);
const _line = Color(0xFFE5E3EF);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final SupabaseProductService _productService = SupabaseProductService();
  final List<ProductModel> _cart = [];

  List<ProductModel> _products = [];
  bool _isLoading = true;
  bool _loadFailed = false;

  int _selectedNav = 0;
  String _activeCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 300000);
  String _condition = 'All';
  double? _maxDistanceKm; // null means any distance
  bool _sortByNearest = false;

  @override
  void initState() {
    super.initState();
    SavedProductsStore.items.addListener(_refreshSavedProducts);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final loc = ref.read(userLocationProvider);
      if (!loc.hasLocation && !loc.isLocating) {
        ref.read(userLocationProvider.notifier).detect();
      }
    });
    _loadProducts();
  }

  Future<void> _initUserLocation() async {
    await ref.read(userLocationProvider.notifier).detect();
  }

  Future<void> _setManualLocation() async {
    final loc = ref.read(userLocationProvider);
    final res = await OsmLocationPickerSheet.show(
      context,
      initialPoint: loc.point,
      initialAddress: loc.hasLocation ? loc.label : null,
    );
    if (res == null || !mounted) return;
    ref.read(userLocationProvider.notifier).setManual(res.point, res.address);
  }

  /// Distances are shown when the buyer's position is known; products without
  /// coordinates keep their neutral placeholder instead of a fake distance.
  String _distanceLabelFor(ProductModel product, LatLng? userLocation) {
    if (userLocation == null ||
        product.latitude == null ||
        product.longitude == null) {
      return product.distance;
    }
    final km = LocationService.instance.calculateDistanceKm(
      userLocation.latitude,
      userLocation.longitude,
      product.latitude!,
      product.longitude!,
    );
    return LocationService.instance.formatDistance(km);
  }

  double? _distanceKmFor(ProductModel product, LatLng? userLocation) {
    if (userLocation == null ||
        product.latitude == null ||
        product.longitude == null) {
      return null;
    }
    return LocationService.instance.calculateDistanceKm(
      userLocation.latitude,
      userLocation.longitude,
      product.latitude!,
      product.longitude!,
    );
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final products = await _productService.fetchActiveProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Supabase Home product read failed: $error');
      if (!mounted) return;
      setState(() {
        _products = [];
        _loadFailed = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    SavedProductsStore.items.removeListener(_refreshSavedProducts);
    _searchController.dispose();
    super.dispose();
  }

  void _refreshSavedProducts() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isSeller = ref.watch(currentSupabaseRoleProvider) == 'seller';
    final userLocation = ref.watch(userLocationProvider);
    final locationPoint = userLocation.point;
    ref.listen<UserLocationState>(userLocationProvider, (previous, next) {
      if (next.message != null && next.message != previous?.message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message!)),
        );
        ref.read(userLocationProvider.notifier).clearMessage();
      }
    });
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              sliver: SliverToBoxAdapter(child: _buildSearch()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              sliver: SliverToBoxAdapter(child: _buildRadiusCard()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              sliver: SliverToBoxAdapter(child: _buildSectionHeader()),
            ),
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: _darkTeal),
                  ),
                ),
              )
            else if (_loadFailed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Text('Could not load listings. Check your connection.'),
                      TextButton(onPressed: _loadProducts, child: const Text('Retry')),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = _visibleProducts[index];
                      final displayProduct = product.copyWith(
                        distance: _distanceLabelFor(product, locationPoint),
                      );
                      return _ProductCard(
                        product: displayProduct,
                        inCart: _cart.any((item) => item.id == product.id),
                        onAddToCart: () => _addToCart(product),
                        onOpen: () => _openProduct(product),
                        isSaved: SavedProductsStore.contains(
                          _productDetails(product),
                        ),
                        onToggleSaved: () => _toggleSaved(product),
                      );
                    },
                    childCount: _visibleProducts.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                ),
              ),
            if (!_isLoading && !_loadFailed && _visibleProducts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: _muted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No preloved items match your filters.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _activeCategory = 'All';
                              _searchController.clear();
                            });
                          },
                          child: const Text('Reset filters'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
      floatingActionButton: isSeller
          ? FloatingActionButton.extended(
              onPressed: () => _openAddProduct(context),
              backgroundColor: _darkTeal,
              foregroundColor: Colors.white,
              elevation: 3,
              icon: const Icon(Icons.add_rounded, size: 24),
              label: Text(
                'Sell Item',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNavigation(isSeller),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THRIFTY',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: _darkTeal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Home',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
        _roundIcon(
          Icons.notifications_none_rounded,
          hasDot: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        const SizedBox(width: 8),
        _cartButton(),
        const SizedBox(width: 8),
        _roundIcon(
          Icons.person_outline_rounded,
          onTap: () => _openProfile(context),
        ),
      ],
    );
  }

  Widget _cartButton() {
    return InkWell(
      onTap: _openCart,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 42,
        height: 42,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(Icons.shopping_cart_outlined, color: _darkTeal),
            ),
            if (_cart.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${_cart.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _roundIcon(IconData icon, {bool hasDot = false, VoidCallback? onTap}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 21, color: _darkTeal),
          ),
        ),
        if (hasDot)
          Positioned(
            right: 1,
            top: 1,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _ink),
            decoration: InputDecoration(
              hintText: 'Search preloved clothes, brands...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _muted,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: _muted),
              filled: true,
              fillColor: _surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(color: _green),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => _openFilters(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _darkTeal,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  InputBorder _border({Color color = Colors.transparent}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildRadiusCard() {
    final userLocation = ref.watch(userLocationProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me_rounded, color: _green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  userLocation.isLocating
                      ? 'Detecting your location...'
                      : userLocation.hasLocation
                          ? 'Near ${userLocation.label}'
                          : 'Location not set',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.refresh_rounded, size: 18, color: _muted),
                tooltip: 'Use my current location',
                onPressed: _initUserLocation,
              ),
              if (!userLocation.hasLocation && !userLocation.isLocating)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_location_alt_outlined,
                      size: 18, color: _darkTeal),
                  tooltip: 'Set location manually',
                  onPressed: _setManualLocation,
                ),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NearbyMapScreen(
                        products: _products,
                        userLocation: userLocation.point,
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _cyanSoft,
                  foregroundColor: _darkTeal,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.map_outlined, size: 16),
                label: Text(
                  'Map',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Radius filter:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _radiusChip('All', null),
                      const SizedBox(width: 6),
                      _radiusChip('3 km', 3.0),
                      const SizedBox(width: 6),
                      _radiusChip('5 km', 5.0),
                      const SizedBox(width: 6),
                      _radiusChip('10 km', 10.0),
                      const SizedBox(width: 6),
                      _radiusChip('25 km', 25.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.swap_vert_rounded, size: 16, color: _muted),
              const SizedBox(width: 6),
              Text(
                'Sort:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(
                  'Default',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: !_sortByNearest,
                onSelected: (_) => setState(() => _sortByNearest = false),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: Text(
                  'Nearest first',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: _sortByNearest,
                onSelected: (userLocation.hasLocation)
                    ? (_) => setState(() => _sortByNearest = true)
                    : null,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _radiusChip(String label, double? km) {
    final isSelected = _maxDistanceKm == km;
    return InkWell(
      onTap: () => setState(() => _maxDistanceKm = km),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? _darkTeal : _background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _darkTeal : _line,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : _muted,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          'Active listings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${_visibleProducts.length} items',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _muted),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildBottomNavigation(bool isSeller) {
    return BottomAppBar(
      color: _surface,
      child: SizedBox(
        height: 58,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'Home', 0, isSeller),
            _navItem(Icons.explore_outlined, 'Explore', 1, isSeller),
            _navItem(
              isSeller ? Icons.sell_outlined : Icons.bookmark_outline_rounded,
              isSeller ? 'Listings' : 'Saved',
              2,
              isSeller,
            ),
            _navItem(Icons.person_outline_rounded, 'Profile', 3, isSeller),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, bool isSeller) {
    final selected = _selectedNav == index;
    return InkWell(
      onTap: () => _onTapNav(context, index, isSeller),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: selected ? _darkTeal : _muted),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? _darkTeal : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapNav(BuildContext context, int index, bool isSeller) {
    setState(() => _selectedNav = index);
    if (index == 1) {
      _openFilters(context);
    } else if (index == 3) {
      _openProfile(context);
    } else if (index == 2) {
      if (isSeller) {
        _openListings(context);
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SavedItemsScreen()));
      }
    }
  }

  Future<void> _openFilters(BuildContext context) async {
    final result = await Navigator.of(context).push<FilterResult>(
      MaterialPageRoute(builder: (_) => const FilterScreen()),
    );
    if (!mounted) return;
    setState(() {
      _selectedNav = 0;
      if (result != null) {
        _activeCategory = result.category;
        _priceRange = RangeValues(result.minPrice, result.maxPrice);
        _condition = result.condition;
        _searchController.text = result.query;
      }
    });
  }

  List<ProductModel> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    final userLocation = ref.read(userLocationProvider).point;

    var filtered = _products.where((product) {
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query);

      final matchesCategory = _activeCategory == 'All' ||
          product.category.toLowerCase() == _activeCategory.toLowerCase() ||
          product.name.toLowerCase().contains(_activeCategory.toLowerCase());

      final grade = product.grade.toUpperCase();
      final matchesCondition = _condition == 'All'
          ? true
          : _condition == 'A'
          ? (grade.contains('GRADE A') || grade.contains('MINT') || grade.contains('LIKE NEW'))
          : grade.contains('GRADE $_condition');

      final matchesRadius = _maxDistanceKm == null
          ? true
          : (product.latitude == null ||
                  product.longitude == null ||
                  userLocation == null)
              // Products without coordinates, or when we have no buyer
              // location, are excluded from radius-filtered results.
              ? false
              : (LocationService.instance.calculateDistanceKm(
                    userLocation.latitude,
                    userLocation.longitude,
                    product.latitude!,
                    product.longitude!,
                  ) <=
                  _maxDistanceKm!);

      return matchesQuery &&
          matchesCategory &&
          product.price >= _priceRange.start &&
          product.price <= _priceRange.end &&
          matchesCondition &&
          matchesRadius;
    }).toList();

    if (_sortByNearest && userLocation != null) {
      filtered.sort((a, b) {
        final da = _distanceKmFor(a, userLocation);
        final db = _distanceKmFor(b, userLocation);
        if (da == null && db == null) return 0;
        if (da == null) return 1; // products without coordinates go last
        if (db == null) return -1;
        return da.compareTo(db);
      });
    }

    return filtered;
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _openListings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SellerOnlyGate(child: MyListingsScreen()),
      ),
    );
  }

  Future<void> _openAddProduct(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SellerOnlyGate(child: AddProductScreen()),
      ),
    );
    await _loadProducts();
  }

  void _openProduct(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: _productDetails(product),
          onAddToCart: () {
            _addToCart(product);
          },
        ),
      ),
    );
  }

  ProductDetailsData _productDetails(ProductModel product) {
    final withDistance = product.copyWith(
      distance: _distanceLabelFor(product, ref.read(userLocationProvider).point),
    );
    return ProductDetailsData.fromModel(withDistance);
  }

  void _toggleSaved(ProductModel product) {
    final details = _productDetails(product);
    SavedProductsStore.toggle(details);
    setState(() {});
    _showLocalMessage(
      SavedProductsStore.contains(details)
          ? 'Saved to your items.'
          : 'Removed from saved items.',
    );
  }

  void _showLocalMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _addToCart(ProductModel product) {
    if (_cart.any((item) => item.id == product.id)) {
      _showLocalMessage('This item is already in your cart.');
      return;
    }
    setState(() => _cart.add(product));
    _showLocalMessage('${product.name} added to your cart.');
  }

  Future<void> _openCart() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _CartScreen(
          items: _cart,
          onRemove: (product) => setState(() => _cart.remove(product)),
          onCheckout: () async {
            final paymentMethod = await Navigator.of(context).push<String>(
              MaterialPageRoute(
                builder: (_) => CheckoutScreen(
                  subtotal: _cartTotal,
                  itemCount: _cart.length,
                ),
              ),
            );
            if (paymentMethod == null || !mounted) return;
            setState(_cart.clear);
            Navigator.of(context).pop();
            _showLocalMessage('Order placed via $paymentMethod.');
          },
        ),
      ),
    );
  }

  int get _cartTotal => _cart.fold(0, (sum, item) => sum + item.price);
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onAddToCart,
    required this.inCart,
    required this.onOpen,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final ProductModel product;
  final VoidCallback onAddToCart;
  final bool inCart;
  final VoidCallback onOpen;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: product.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _fallbackCover(),
                      errorWidget: (context, url, error) => _fallbackCover(),
                    )
                  else
                    _fallbackCover(),
                  Positioned(top: 9, left: 9, child: _gradePill(product.grade)),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: isSaved ? 'Remove saved item' : 'Save item',
                        onPressed: onToggleSaved,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isSaved ? const Color(0xFFDC2626) : _darkTeal,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 9,
                    child: _distancePill(product.distance),
                  ),
                  Positioned(
                    bottom: 7,
                    right: 7,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: inCart ? 'Already in cart' : 'Add to cart',
                        onPressed: onAddToCart,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          inCart
                              ? Icons.shopping_cart_rounded
                              : Icons.add_shopping_cart_rounded,
                          size: 18,
                          color: _darkTeal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: _tealText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded, size: 14, color: _green),
                        const SizedBox(width: 2),
                        Text(
                          product.rating,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    _labelPill(
                      'Pickup: ${product.pickupLocation}',
                      const Color(0xFFF1F2F4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: const Color(0xFFD9E8EA),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checkroom_rounded, size: 40, color: Color(0xFF4F7880)),
            SizedBox(height: 4),
            Text('No photo'),
          ],
        ),
      ),
    );
  }

  Widget _labelPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: _muted,
        ),
      ),
    );
  }

  Widget _gradePill(String grade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _cyanSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        grade,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: _darkTeal,
        ),
      ),
    );
  }

  Widget _distancePill(String distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: _darkTeal,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        distance,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CartScreen extends StatefulWidget {
  const _CartScreen({
    required this.items,
    required this.onRemove,
    required this.onCheckout,
  });

  final List<ProductModel> items;
  final ValueChanged<ProductModel> onRemove;
  final Future<void> Function() onCheckout;

  @override
  State<_CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<_CartScreen> {
  late final List<ProductModel> _items = List.of(widget.items);

  int get _total => _items.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        title: Text(
          'My cart (${_items.length})',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 52,
                    color: _muted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _line),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item.imageUrls.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.imageUrls.first,
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    _cartPlaceholder(),
                                errorWidget: (context, url, error) =>
                                    _cartPlaceholder(),
                              )
                            : _cartPlaceholder(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            Text(
                              item.brand,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: _muted,
                              ),
                            ),
                            Text(
                              item.formattedPrice,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _darkTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove from cart',
                        onPressed: () {
                          final removed = _items.removeAt(index);
                          setState(() {});
                          widget.onRemove(removed);
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: _surface,
                  border: Border(top: BorderSide(color: _line)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Subtotal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: _muted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Rp $_total',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => widget.onCheckout(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkTeal,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _cartPlaceholder() {
    return Container(
      width: 58,
      height: 58,
      color: const Color(0xFFD9E8EA),
      child: const Icon(Icons.checkroom_rounded, color: Color(0xFF4F7880)),
    );
  }
}

const _tealText = Color(0xFF0E7490);
