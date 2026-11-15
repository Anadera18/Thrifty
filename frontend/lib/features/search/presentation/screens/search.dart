import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:thrifty/features/product_detail/presentation/screens/product_detail.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/services/supabase_product_service.dart';

const Color _green = Color(0xFF006400);
const Color _background = Color(0xFFF8F9FB);

// ============================================================
// HALAMAN FILTER AND SEARCH
// ============================================================

class FilterSearchScreen extends StatefulWidget {
  const FilterSearchScreen({super.key});

  @override
  State<FilterSearchScreen> createState() => _FilterSearchScreenState();
}

class _FilterSearchScreenState extends State<FilterSearchScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  double _priceValue = 1000000;
  int _selectedPriceChip = 2;
  String _selectedCategory = 'All';

  final Map<String, bool> _conditions = {
    'Grade A': true,
    'Grade B': true,
    'Grade C': true,
    'Grade D': true,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          query: _searchController.text,
          category: _selectedCategory,
          maxPrice: _selectedPriceChip == 2 ? double.infinity : _priceValue,
          conditions: Map<String, bool>.from(_conditions),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _priceValue = 1000000;
      _selectedPriceChip = 2;
      _selectedCategory = 'All';
      _conditions.updateAll((key, value) => true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.shopping_bag_outlined, color: _green),
            SizedBox(width: 8),
            Text(
              'THRIFTY',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Filter And Search',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sell an item',
            icon: const Icon(Icons.add_circle_outline, color: _green),
            onPressed: () => Navigator.pushNamed(context, '/sell-item'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _resetFilters,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black87,
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH INPUT
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black87),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _showResults(),
                      decoration: const InputDecoration(
                        hintText: 'Search thrift products...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _searchController.clear,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // LOCATION
            const Row(
              children: [
                Icon(Icons.near_me, size: 15, color: _green),
                SizedBox(width: 6),
                Text(
                  'Search active listings by their saved item details',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // DISTANCE NOTE
            _sectionCard(
              child: const Text(
                'Distance filtering is not available yet. Search uses item details, category, price, and condition.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // PRICE RANGE
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle(
                    Icons.account_balance_wallet_outlined,
                    'Price range',
                    'Up to Rp ${_priceValue.toInt()}',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _priceChip(0, 'Under 100k'),
                      const SizedBox(width: 6),
                      _priceChip(1, 'Up to 150k'),
                      const SizedBox(width: 6),
                      _priceChip(2, 'Any price'),
                    ],
                  ),
                  Slider(
                    value: _priceValue,
                    min: 0,
                    max: 1000000,
                    divisions: 50,
                    activeColor: _green,
                    onChanged: (value) {
                      setState(() {
                        _priceValue = value;
                        _selectedPriceChip = -1;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rp 0',
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        'Rp ${_priceValue.toInt()}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Rp 1.000.000',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CATEGORY
            const Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _categoryCard('All', Icons.apps),
                _categoryCard('Shirt', Icons.checkroom),
                _categoryCard('T-Shirt', Icons.dry_cleaning),
                _categoryCard('Pants', Icons.shopping_bag),
                _categoryCard('Jacket', Icons.ac_unit),
              ],
            ),
            const SizedBox(height: 20),

            // CONDITION
            const Text(
              'CONDITION GRADE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            _conditionCard(
              'Grade A',
              'Like New',
            ),
            const SizedBox(height: 8),
            _conditionCard(
              'Grade B',
              'Very Good',
            ),
            const SizedBox(height: 8),
            _conditionCard(
              'Grade C',
              'Good / Usable',
            ),
            const SizedBox(height: 8),
            _conditionCard(
              'Grade D',
              'Significant Wear',
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _showResults,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Show results',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _cardTitle(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: _green, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: _green,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceChip(int index, String label) {
    final selected = _selectedPriceChip == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriceChip = index;

            if (index == 0) {
              _priceValue = 99999;
            } else if (index == 1) {
              _priceValue = 150000;
            } else {
              _priceValue = 1000000;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _green : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryCard(String name, IconData icon) {
    final selected = _selectedCategory == name;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _green : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _green : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _conditionCard(String grade, String description) {
    final selected = _conditions[grade] ?? false;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _conditions[grade] = !selected;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                grade.replaceAll('Grade ', ''),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        grade,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: selected ? _green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HALAMAN HASIL PENCARIAN
// ============================================================

class SearchResultsScreen extends StatefulWidget {
  final String query;
  final String category;
  final double maxPrice;
  final Map<String, bool> conditions;

  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.category,
    required this.maxPrice,
    required this.conditions,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final SupabaseProductService _productService = SupabaseProductService();
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.fetchActiveProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        title: const Text(
          'Search Results',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load listings. Check your connection and try again.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _productsFuture = _productService.fetchActiveProducts();
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allProducts = snapshot.data ?? const <ProductModel>[];
          final normalizedQuery = widget.query.trim().toLowerCase();
          final filteredProducts = allProducts.where((product) {
            final searchable = '${product.name} ${product.brand} ${product.category} ${product.pickupLocation}'.toLowerCase();
            final matchesQuery = normalizedQuery.isEmpty || searchable.contains(normalizedQuery);
            final matchesCategory = widget.category == 'All' || product.category == widget.category;
            final matchesPrice = product.price <= widget.maxPrice;
            final matchesCondition = widget.conditions[product.grade] ?? false;
            return matchesQuery && matchesCategory && matchesPrice && matchesCondition;
          }).toList(growable: false);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${filteredProducts.length} listings found', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 10),
                const Text('Distance filtering is unavailable; pickup locations are shown on each listing.', style: TextStyle(color: Colors.black45, fontSize: 12)),
                const SizedBox(height: 14),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 60, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('No listings match these filters', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              SizedBox(height: 6),
                              Text('Try changing your search or filters.', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          itemCount: filteredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.62),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: ProductDetailsData.fromModel(product)))),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: product.imageUrls.isEmpty
                                            ? const Center(child: Text('No photo', style: TextStyle(color: Colors.grey)))
                                            : CachedNetworkImage(
                                                imageUrl: product.imageUrls.first,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                                errorWidget: (_, __, ___) => const Center(child: Text('No photo', style: TextStyle(color: Colors.grey))),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const SizedBox(height: 6),
                                        Text(product.formattedPrice, style: const TextStyle(color: _green, fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 5),
                                        Text(product.grade, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                        const SizedBox(height: 5),
                                        Text(product.pickupLocation.isEmpty ? 'Pickup location unavailable' : product.pickupLocation, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
