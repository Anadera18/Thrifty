import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../my_listings/presentation/screens/my_listings_screen.dart';
import 'filter_screen.dart';

const _background = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _green = Color(0xFF14532D);
const _darkTeal = Color(0xFF0E3436);
const _cyanSoft = Color(0xFFCFF5FA);
const _line = Color(0xFFE5E3EF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final List<_Product> _cart = [];
  int _selectedNav = 0;
  double _radius = 5;
  String _activeCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 150000);
  String _condition = 'A';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ProductCard(
                    product: _visibleProducts[index],
                    inCart: _cart.contains(_visibleProducts[index]),
                    onAddToCart: () => _addToCart(_visibleProducts[index]),
                  ),
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
            if (_visibleProducts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No items match these filters.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: _muted,
                      ),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showLocalMessage('Add listing is ready for your next item.'),
        backgroundColor: _darkTeal,
        foregroundColor: Colors.white,
        elevation: 3,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigation(),
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
        _roundIcon(Icons.notifications_none_rounded, hasDot: true),
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
              hintText: 'Search preloved items...',
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Search radius',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(width: 8),
              _softPill('Within ${_radius.round()} km', _cyanSoft),
              const Spacer(),
              Text(
                'Walking & transit',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _darkTeal,
              inactiveTrackColor: _line,
              thumbColor: _darkTeal,
              overlayColor: _cyanSoft,
              trackHeight: 4,
            ),
            child: Slider(
              value: _radius.clamp(1, 10),
              min: 1,
              max: 10,
              onChanged: (value) => setState(() => _radius = value),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _caption('1 km'),
              _caption('5 km (Default)'),
              _caption('10 km'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _softPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: _darkTeal,
        ),
      ),
    );
  }

  Widget _caption(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _muted),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          'Nearby drops',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${_visibleProducts.length} items nearby',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _muted),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () => _showLocalMessage('Sorted by nearest items.'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: _darkTeal,
          ),
          icon: const Icon(Icons.sort_rounded, size: 16),
          label: Text(
            'Nearest',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return BottomAppBar(
      color: _surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 58,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'Home', 0),
            _navItem(Icons.explore_outlined, 'Explore', 1),
            const SizedBox(width: 44),
            _navItem(Icons.sell_outlined, 'Listings', 2),
            _navItem(Icons.person_outline_rounded, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _selectedNav == index;
    return InkWell(
      onTap: () => _onTapNav(context, index),
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

  void _onTapNav(BuildContext context, int index) {
    setState(() => _selectedNav = index);
    if (index == 1) {
      _openFilters(context);
    } else if (index == 3) {
      _openProfile(context);
    } else if (index == 2) {
      _openListings(context);
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
        _radius = result.radius;
        _activeCategory = result.category;
        _priceRange = RangeValues(result.minPrice, result.maxPrice);
        _condition = result.condition;
        _searchController.text = result.query;
      }
    });
  }

  List<_Product> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((product) {
      final matchesQuery =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query);
      final matchesCategory =
          _activeCategory == 'All' ||
          switch (_activeCategory) {
            'Shirt' => product.name.toLowerCase().contains('shirt'),
            'T-Shirt' => product.name.toLowerCase().contains('tee'),
            'Pants' => product.name.toLowerCase().contains('pants'),
            'Jacket' => product.name.toLowerCase().contains('jacket'),
            _ => true,
          };
      final price =
          int.tryParse(product.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final distance = _distanceInKm(product.distance);
      final grade = product.grade.toUpperCase();
      final matchesCondition = _condition == 'A'
          ? grade.startsWith('GRADE A')
          : grade.startsWith('GRADE $_condition');
      return matchesQuery &&
          matchesCategory &&
          price >= _priceRange.start &&
          price <= _priceRange.end &&
          distance <= _radius &&
          matchesCondition;
    }).toList();
  }

  double _distanceInKm(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.endsWith('km')) {
      return double.tryParse(
            normalized.substring(0, normalized.length - 2).trim(),
          ) ??
          double.infinity;
    }
    if (normalized.endsWith('m')) {
      final meters = double.tryParse(
        normalized.substring(0, normalized.length - 1).trim(),
      );
      return meters == null ? double.infinity : meters / 1000;
    }
    return double.tryParse(normalized) ?? double.infinity;
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _openListings(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const MyListingsScreen()));
  }

  void _showLocalMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _addToCart(_Product product) {
    if (_cart.contains(product)) {
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
          onCheckout: () {
            setState(_cart.clear);
            Navigator.of(context).pop();
            _showLocalMessage('Checkout complete (demo).');
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onAddToCart,
    required this.inCart,
  });

  final _Product product;
  final VoidCallback onAddToCart;
  final bool inCart;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Container(color: product.placeholderColor),
                Center(
                  child: Icon(product.icon, size: 44, color: product.iconColor),
                ),
                Positioned(top: 9, left: 9, child: _gradePill(product.grade)),
                const Positioned(
                  top: 7,
                  right: 7,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 19,
                      color: _darkTeal,
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
                        product.price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
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
                  _labelPill('Local pickup', const Color(0xFFF1F2F4)),
                ],
              ),
            ),
          ),
        ],
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

  final List<_Product> items;
  final ValueChanged<_Product> onRemove;
  final VoidCallback onCheckout;

  @override
  State<_CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<_CartScreen> {
  late final List<_Product> _items = List.of(widget.items);

  int get _total => _items.fold(
    0,
    (sum, item) =>
        sum + (int.tryParse(item.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0),
  );

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
              separatorBuilder: (_, _) => const SizedBox(height: 10),
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
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: item.placeholderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
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
                              item.price,
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
                          setState(() => _items.removeAt(index));
                          widget.onRemove(item);
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
                          'Rp ${_total.toString()}',
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
                        onPressed: widget.onCheckout,
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
}

const _tealText = Color(0xFF0E7490);

class _Product {
  const _Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.distance,
    required this.rating,
    required this.grade,
    required this.placeholderColor,
    required this.iconColor,
    required this.icon,
  });

  final String name;
  final String brand;
  final String price;
  final String distance;
  final String rating;
  final String grade;
  final Color placeholderColor;
  final Color iconColor;
  final IconData icon;
}

const _products = [
  _Product(
    name: 'Washed Denim Jacket',
    brand: 'Vintage Levi’s',
    price: 'Rp 145.000',
    distance: '800 m',
    rating: '4.9',
    grade: 'Grade A+ • Mint',
    placeholderColor: Color(0xFFD9E8EA),
    iconColor: Color(0xFF4F7880),
    icon: Icons.checkroom_rounded,
  ),
  _Product(
    name: 'Heavyweight Boxy Tee',
    brand: 'Uniqlo U',
    price: 'Rp 89.000',
    distance: '1.2 km',
    rating: '4.8',
    grade: 'Grade A • Like New',
    placeholderColor: Color(0xFFE9E1D4),
    iconColor: Color(0xFF947D62),
    icon: Icons.dry_cleaning_outlined,
  ),
  _Product(
    name: 'Pied Wide Leg Pants',
    brand: 'Dickies 874',
    price: 'Rp 120.000',
    distance: '2.4 km',
    rating: '4.7',
    grade: 'Grade B • Good',
    placeholderColor: Color(0xFFDCE0CC),
    iconColor: Color(0xFF7B8660),
    icon: Icons.airline_seat_legroom_extra_rounded,
  ),
  _Product(
    name: 'Corduroy Detroit Jacket',
    brand: 'Carhartt WIP',
    price: 'Rp 210.000',
    distance: '3.1 km',
    rating: '5.0',
    grade: 'Grade A • Like New',
    placeholderColor: Color(0xFFD8E1D8),
    iconColor: Color(0xFF50715D),
    icon: Icons.shopping_bag_outlined,
  ),
  _Product(
    name: 'Flannel Check Shirt',
    brand: 'Polo Ralph Lauren',
    price: 'Rp 175.000',
    distance: '3.8 km',
    rating: '4.9',
    grade: 'Grade A+ • Mint',
    placeholderColor: Color(0xFFE2D9D1),
    iconColor: Color(0xFF8B6555),
    icon: Icons.grid_4x4_rounded,
  ),
  _Product(
    name: 'Faded World Tour Tee',
    brand: 'Stüssy Archive',
    price: 'Rp 95.000',
    distance: '4.1 km',
    rating: '4.6',
    grade: 'Grade B • Very Good',
    placeholderColor: Color(0xFFD9DDE2),
    iconColor: Color(0xFF647486),
    icon: Icons.photo_size_select_actual_outlined,
  ),
];
