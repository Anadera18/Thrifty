import 'package:flutter/material.dart';
import 'package:thrifty/features/product_detail/presentation/screens/product_detail.dart';

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
      TextEditingController(text: 'denim');

  double _radiusValue = 5;
  double _priceValue = 75000;
  int _selectedPriceChip = 1;
  String _selectedCategory = 'Jacket';

  final Map<String, bool> _conditions = {
    'Grade A': true,
    'Grade B': true,
    'Grade C': false,
    'Grade D': false,
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
          maxPrice: _priceValue,
          conditions: Map<String, bool>.from(_conditions),
          radius: _radiusValue,
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.text = 'denim';
      _radiusValue = 5;
      _priceValue = 75000;
      _selectedPriceChip = 1;
      _selectedCategory = 'Jacket';
      _conditions.updateAll((key, value) =>
          key == 'Grade A' || key == 'Grade B');
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
                  'Browsing near South Jakarta',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // SEARCH RADIUS
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle(
                    Icons.radar,
                    'Search radius',
                    '${_radiusValue.toInt()} km',
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Showing vintage shops and sellers within your selected radius.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Slider(
                    value: _radiusValue,
                    min: 1,
                    max: 10,
                    activeColor: _green,
                    onChanged: (value) {
                      setState(() => _radiusValue = value);
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 km'),
                      Text('5 km'),
                      Text('10 km'),
                    ],
                  ),
                ],
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
                      _priceChip(1, '100k–150k'),
                      const SizedBox(width: 6),
                      _priceChip(2, '150k+'),
                    ],
                  ),
                  Slider(
                    value: _priceValue,
                    min: 0,
                    max: 150000,
                    divisions: 30,
                    activeColor: _green,
                    onChanged: (value) {
                      setState(() {
                        _priceValue = value;
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
                        'Rp 150.000',
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
                _categoryCard('Shirt', Icons.checkroom),
                _categoryCard('T-Shirt', Icons.dry_cleaning),
                _categoryCard('Pants', Icons.shopping_bag),
                _categoryCard('Jacket', Icons.ac_unit),
              ],
            ),
            const SizedBox(height: 20),

            // CONDITION
            const Row(
              children: [
                Text(
                  'CONDITION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome, color: Colors.blue, size: 14),
                Text(
                  'AI VERIFIED',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _conditionCard(
              'Grade A',
              '9/10',
              'Excellent condition, minimal signs of wear',
            ),
            const SizedBox(height: 8),
            _conditionCard(
              'Grade B',
              '7–8/10',
              'Good vintage patina, gentle authentic wear',
            ),
            const SizedBox(height: 8),
            _conditionCard(
              'Grade C',
              '5–6/10',
              'Fair condition, visible distressed character',
            ),
            const SizedBox(height: 8),
            _conditionCard(
              'Grade D',
              'Upcycle',
              'Raw project piece, ideal for DIY reconstruction',
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
              _priceValue = 150000;
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

  Widget _conditionCard(String grade, String score, String description) {
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
                      const SizedBox(width: 6),
                      Text(
                        score,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
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

class SearchResultsScreen extends StatelessWidget {
  final String query;
  final String category;
  final double maxPrice;
  final Map<String, bool> conditions;
  final double radius;

  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.category,
    required this.maxPrice,
    required this.conditions,
    required this.radius,
  });

  // Data contoh lokal untuk tampilan.
  // Nantinya dapat diganti dengan data dari backend/API.
  static const List<Map<String, dynamic>> _products = [
    {
      'name': 'Vintage Denim Jacket',
      'price': 89000,
      'grade': 'Grade A',
      'category': 'Jacket',
      'location': 'South Jakarta',
      'image':
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=700',
    },
    {
      'name': 'Classic Denim Jacket',
      'price': 120000,
      'grade': 'Grade B',
      'category': 'Jacket',
      'location': 'Central Jakarta',
      'image':
          'https://images.unsplash.com/photo-1543076447-215ad9ba6923?w=700',
    },
    {
      'name': 'Vintage Cotton Shirt',
      'price': 65000,
      'grade': 'Grade A',
      'category': 'Shirt',
      'location': 'South Jakarta',
      'image':
          'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=700',
    },
    {
      'name': 'Vintage Denim Pants',
      'price': 95000,
      'grade': 'Grade B',
      'category': 'Pants',
      'location': 'West Jakarta',
      'image':
          'https://images.unsplash.com/photo-1542272604-787c3835535d?w=700',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();

    final filteredProducts = _products.where((product) {
      final matchesQuery = normalizedQuery.isEmpty ||
          product['name'].toString().toLowerCase().contains(normalizedQuery);

      final matchesCategory = product['category'] == category;
      final matchesPrice = (product['price'] as int) <= maxPrice;
      final matchesCondition =
          conditions[product['grade']] ?? false;

      return matchesQuery &&
          matchesCategory &&
          matchesPrice &&
          matchesCondition;
    }).toList();

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${filteredProducts.length} products found',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Try changing your search or filters.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProductDetailScreen(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Image.network(
                                      product['image'].toString(),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Icon(
                                              Icons.checkroom,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'].toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Rp ${(product['price'] as int).toString()}',
                                        style: const TextStyle(
                                          color: _green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        product['grade'].toString(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 12,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              product['location'].toString(),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}
