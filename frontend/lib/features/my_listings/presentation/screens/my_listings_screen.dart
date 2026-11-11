import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../../../add_product/presentation/screens/add_product_screen.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/services/firestore_product_service.dart';

const _bg = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _darkTeal = Color(0xFF0E3436);
const _line = Color(0xFFE5E3EF);

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final FirestoreProductService _productService = FirestoreProductService();
  StreamSubscription? _listingsSub;
  List<ProductModel> _items = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0: Active, 1: Sold, 2: Drafts

  @override
  void initState() {
    super.initState();
    _subscribeListings();
  }

  void _subscribeListings() {
    _listingsSub = _productService.streamActiveProducts().listen(
      (snapshot) {
        if (!mounted) return;
        setState(() {
          _items = snapshot.docs.map(ProductModel.fromFirestore).toList();
          _isLoading = false;
        });
      },
      onError: (err) {
        debugPrint('MyListings stream error: $err');
        if (!mounted) return;
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _listingsSub?.cancel();
    super.dispose();
  }

  List<ProductModel> get _filteredItems {
    if (_selectedTab == 1) {
      return _items.where((i) => i.status == 'sold').toList();
    } else if (_selectedTab == 2) {
      return _items.where((i) => i.status == 'draft').toList();
    }
    return _items.where((i) => i.status == 'active').toList();
  }

  int get _totalActiveValue =>
      _items.where((i) => i.status == 'active').fold(0, (sum, i) => sum + i.price);

  @override
  Widget build(BuildContext context) {
    final activeCount = _items.where((i) => i.status == 'active').length;
    final soldCount = _items.where((i) => i.status == 'sold').length;

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
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        children: [
          Text(
            'Manage your wardrobe archive on Cloud Firestore',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted),
          ),
          const SizedBox(height: 18),
          _buildTabs(activeCount, soldCount),
          const SizedBox(height: 14),
          _buildSnapshot(),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: _darkTeal),
              ),
            )
          else if (_filteredItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 44,
                      color: _muted,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedTab == 0
                          ? 'No active listings in database yet.'
                          : 'No items in this tab.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._filteredItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ListingCard(
                  listing: item,
                  onDelete: () => _deleteListing(item),
                  onToggleSold: () => _toggleSoldStatus(item),
                  onEdit: () => _editListing(item),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduct,
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

  Widget _buildTabs(int activeCount, int soldCount) {
    final labels = ['Active $activeCount', 'Sold $soldCount', 'Drafts'];
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
                  'ACTIVE WARDROBE VALUE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _darkTeal,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp $_totalActiveValue',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                Text(
                  '${_items.length} items cataloged in Firestore',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openAddProduct,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add'),
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

  Future<void> _openAddProduct() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
  }

  Future<void> _deleteListing(ProductModel listing) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: Text('Remove "${listing.name}" permanently from Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _productService.deleteProduct(listing.id);
      _showMessage('${listing.name} deleted from Firestore.');
    } catch (e) {
      _showMessage('Error deleting listing: $e');
    }
  }

  Future<void> _toggleSoldStatus(ProductModel listing) async {
    final nextStatus = listing.status == 'sold' ? 'active' : 'sold';
    try {
      await _productService.updateProduct(listing.id, {'status': nextStatus});
      _showMessage(
        nextStatus == 'sold'
            ? 'Marked as Sold!'
            : 'Relisted as Active item.',
      );
    } catch (e) {
      _showMessage('Failed to update status: $e');
    }
  }

  Future<void> _editListing(ProductModel listing) async {
    final nameCtrl = TextEditingController(text: listing.name);
    final priceCtrl = TextEditingController(text: listing.price.toString());
    final brandCtrl = TextEditingController(text: listing.brand);
    String selectedGrade = listing.grade;

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(
            'Edit Listing',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: brandCtrl,
                  decoration: const InputDecoration(labelText: 'Brand'),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (Rp)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: ['Grade A · Like new', 'Grade B · Very good', 'Grade C · Good / Usable', 'Grade D · Significant wear', 'Grade A', 'Grade B', 'Grade C', 'Grade D']
                          .contains(selectedGrade)
                      ? selectedGrade
                      : 'Grade A · Like new',
                  decoration: const InputDecoration(labelText: 'Condition Grade'),
                  items: const [
                    DropdownMenuItem(value: 'Grade A · Like new', child: Text('Grade A · Like new')),
                    DropdownMenuItem(value: 'Grade B · Very good', child: Text('Grade B · Very good')),
                    DropdownMenuItem(value: 'Grade C · Good / Usable', child: Text('Grade C · Good / Usable')),
                    DropdownMenuItem(value: 'Grade D · Significant wear', child: Text('Grade D · Significant wear')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedGrade = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkTeal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (updated != true) return;

    try {
      final newPrice = int.tryParse(priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? listing.price;
      await _productService.updateProduct(listing.id, {
        'name': nameCtrl.text.trim(),
        'brand': brandCtrl.text.trim(),
        'price': newPrice,
        'grade': selectedGrade,
      });
      _showMessage('Listing updated successfully!');
    } catch (e) {
      _showMessage('Failed to update listing: ');
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.onDelete,
    required this.onToggleSold,
    required this.onEdit,
  });

  final ProductModel listing;
  final VoidCallback onDelete;
  final VoidCallback onToggleSold;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final hasImage = listing.imageUrls.isNotEmpty;
    final isSold = listing.status == 'sold';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: hasImage
                  ? Image.network(
                      listing.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _fallbackCover(),
                    )
                  : _fallbackCover(),
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
                      listing.category.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: _darkTeal,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSold
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFFCFF5FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSold ? 'SOLD' : listing.grade,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isSold ? Colors.grey.shade700 : _darkTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  listing.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                Text(
                  '${listing.brand} • Size ${listing.size}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      listing.formattedPrice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onToggleSold,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        isSold ? 'Relist' : 'Mark Sold',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit listing',
                      onPressed: onEdit,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 19,
                        color: _darkTeal,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete listing',
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: const Color(0xFFD9E8EA),
      child: const Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 32,
          color: Color(0xFF4F7880),
        ),
      ),
    );
  }
}
