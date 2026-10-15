import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../home/presentation/screens/home_screen.dart';

const _bg = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _darkTeal = Color(0xFF0E3436);
const _cyanSoft = Color(0xFFCFF5FA);
const _line = Color(0xFFE5E3EF);

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  int _selectedTab = 0;
  final _items = <_Listing>[
    const _Listing(
      category: 'OUTERWEAR',
      name: 'Vintage Denim Jacket',
      detail: 'Jacket • Size L (Oversized)',
      price: 'Rp 89.000',
      views: '42',
      age: 'Listed 2d ago',
      color: Color(0xFFD9E8EA),
      icon: Icons.checkroom_rounded,
      grade: 'Grade A',
    ),
    const _Listing(
      category: 'STREETWEAR',
      name: 'Urban Nomad Graphic Tee',
      detail: 'T-Shirt • Size M • Charcoal',
      price: 'Rp 65.000',
      views: '29',
      age: 'Listed 4d ago',
      color: Color(0xFFE5DDD5),
      icon: Icons.dry_cleaning_outlined,
      grade: 'Grade B • Very Good',
    ),
    const _Listing(
      category: 'TROUSERS',
      name: 'Washed Corduroy Trousers',
      detail: 'Pants • Waist 32 • Warm Brown',
      price: 'Rp 170.000',
      views: '13',
      age: 'Listed 5d ago',
      color: Color(0xFFDCE0CC),
      icon: Icons.airline_seat_legroom_extra_rounded,
      grade: 'Archival',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: Text(
          'My listings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: () => _goHome(),
            icon: const Icon(Icons.home_outlined, color: _ink),
          ),
          IconButton(
            onPressed: () => _showMessage('Listing filters are ready.'),
            icon: const Icon(Icons.tune_rounded, color: _darkTeal),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        children: [
          Text(
            'Manage your wardrobe archive',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _muted),
          ),
          const SizedBox(height: 18),
          _buildTabs(),
          const SizedBox(height: 14),
          _buildSnapshot(),
          const SizedBox(height: 16),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ListingCard(
                listing: item,
                onEdit: () => _showMessage('Edit listing is ready.'),
                onDelete: () => _deleteListing(item),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createListing,
        backgroundColor: _darkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New listing',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    const labels = ['Active 3', 'Sold 14', 'Drafts'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? _darkTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _ink,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSnapshot() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY SNAPSHOT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _darkTeal,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp 324.000',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                Text(
                  '84 views captured this week',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _createListing,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Drop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteListing(_Listing listing) {
    setState(() => _items.remove(listing));
    _showMessage('${listing.name} removed from your listings.');
  }

  Future<void> _createListing() async {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New listing'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an item name'
                    : null,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (IDR)'),
                validator: (value) {
                  final price = int.tryParse(value?.replaceAll('.', '') ?? '');
                  return price == null || price <= 0
                      ? 'Enter a valid price'
                      : null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Add item'),
          ),
        ],
      ),
    );

    if (shouldSave == true && mounted) {
      final price = int.parse(priceController.text.replaceAll('.', ''));
      setState(() {
        _selectedTab = 0;
        _items.insert(
          0,
          _Listing(
            category: 'NEW ARRIVAL',
            name: titleController.text.trim(),
            detail: 'Preloved item • Condition not graded',
            price: 'Rp ${price.toString()}',
            views: '0',
            age: 'Listed just now',
            color: const Color(0xFFD9E8EA),
            icon: Icons.checkroom_rounded,
            grade: 'Pending grade',
          ),
        );
      });
      _showMessage('Listing added to your active items.');
    }
    titleController.dispose();
    priceController.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _goHome() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.onEdit,
    required this.onDelete,
  });

  final _Listing listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 104,
                height: 120,
                decoration: BoxDecoration(
                  color: listing.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(listing.icon, size: 48, color: _darkTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            listing.category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _muted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          _gradePill(listing.grade),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        listing.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        listing.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: _muted,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            listing.price,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.visibility_outlined,
                            size: 15,
                            color: _muted,
                          ),
                          const SizedBox(width: 3),
                          Text(listing.views, style: _captionStyle()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(listing.age, style: _captionStyle()),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: _darkTeal,
                    backgroundColor: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradePill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: _cyanSoft,
        borderRadius: BorderRadius.circular(999),
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

  TextStyle _captionStyle() =>
      GoogleFonts.plusJakartaSans(fontSize: 11, color: _muted);
}

class _Listing {
  const _Listing({
    required this.category,
    required this.name,
    required this.detail,
    required this.price,
    required this.views,
    required this.age,
    required this.color,
    required this.icon,
    required this.grade,
  });

  final String category;
  final String name;
  final String detail;
  final String price;
  final String views;
  final String age;
  final Color color;
  final IconData icon;
  final String grade;
}
