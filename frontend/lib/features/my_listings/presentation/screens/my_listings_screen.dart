import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/widgets/seller_only_gate.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../add_product/presentation/screens/add_product_screen.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/services/supabase_product_service.dart';

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
  final SupabaseProductService _productService = SupabaseProductService();
  List<ProductModel> _items = [];
  bool _isLoading = true;
  bool _isMutating = false;
  Object? _loadError;
  int _selectedTab = 0; // 0: Active, 1: Sold

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    final sellerId = Supabase.instance.client.auth.currentUser?.id;
    if (sellerId == null) {
      if (mounted) setState(() { _loadError = StateError('No signed-in seller.'); _isLoading = false; });
      return;
    }
    setState(() { _isLoading = true; _loadError = null; });
    try {
      final rows = await _productService.fetchSellerProducts(sellerId);
      if (!mounted) return;
      setState(() { _items = rows; _isLoading = false; });
    } catch (error) {
      debugPrint('My Listings load error: $error');
      if (!mounted) return;
      setState(() { _loadError = error; _isLoading = false; });
    }
  }

  List<ProductModel> get _filteredItems {
    if (_selectedTab == 1) {
      return _items.where((i) => i.status == 'sold').toList();
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
            'Your active and sold listings',
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
          else if (_loadError != null)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(children: [
                const Icon(Icons.cloud_off_outlined, size: 42, color: _muted),
                const SizedBox(height: 8),
                const Text('Could not load your listings.'),
                const SizedBox(height: 8),
                TextButton(onPressed: _loadListings, child: const Text('Retry')),
              ]),
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
                          ? 'You have no active listings yet.'
                          : 'You have no sold listings yet.',
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
                  isBusy: _isMutating,
                  onEdit: () => _editListing(item),
                  onMarkSold: () => _markSold(item),
                  onDelete: () => _deleteListing(item),
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
    final labels = ['Active $activeCount', 'Sold $soldCount'];
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
                  '${_items.length} of your Supabase listings',
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
      MaterialPageRoute(
        builder: (_) => const SellerOnlyGate(child: AddProductScreen()),
      ),
    );
    if (mounted) _loadListings();
  }

  Future<void> _editListing(ProductModel listing) async {
    final editValues = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditListingDialog(listing: listing),
    );
    if (!mounted || editValues == null) return;
    await _runOwnerAction(
      () => _productService.updateProductDetails(
        productId: listing.id,
        name: editValues['name'] as String,
        brand: editValues['brand'] as String,
        size: editValues['size'] as String,
        category: editValues['category'] as String,
        price: editValues['price'] as int,
        description: editValues['description'] as String,
        pickupLocation: editValues['pickup_location'] as String,
      ),
      'Listing updated.',
    );
  }

  Future<void> _markSold(ProductModel listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as sold?'),
        content: Text('“${listing.name}” will move to your Sold tab.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Mark sold'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _runOwnerAction(
      () => _productService.markProductSold(listing.id),
      'Listing marked as sold.',
    );
  }

  Future<void> _deleteListing(ProductModel listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('“${listing.name}” will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _runOwnerAction(
      () => _productService.deleteProduct(listing.id),
      'Listing deleted.',
    );
  }

  Future<void> _runOwnerAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (_isMutating) return;
    setState(() => _isMutating = true);
    try {
      await action();
      if (!mounted) return;
      await _loadListings();
      if (mounted) _showMessage(successMessage);
    } catch (error) {
      if (mounted) _showMessage('Could not update listing: $error');
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }
}

class _EditListingDialog extends StatefulWidget {
  const _EditListingDialog({required this.listing});

  final ProductModel listing;

  @override
  State<_EditListingDialog> createState() => _EditListingDialogState();
}

class _EditListingDialogState extends State<_EditListingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _sizeController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late String _category;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _nameController = TextEditingController(text: listing.name);
    _brandController = TextEditingController(text: listing.brand);
    _sizeController = TextEditingController(text: listing.size);
    _priceController = TextEditingController(text: listing.price.toString());
    _descriptionController = TextEditingController(text: listing.description);
    _locationController = TextEditingController(text: listing.pickupLocation);
    _category = listing.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit listing'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  maxLength: 160,
                  decoration: const InputDecoration(labelText: 'Item name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an item name.'
                      : null,
                ),
                TextFormField(
                  controller: _brandController,
                  maxLength: 120,
                  decoration: const InputDecoration(labelText: 'Brand'),
                ),
                TextFormField(
                  controller: _sizeController,
                  maxLength: 40,
                  decoration: const InputDecoration(labelText: 'Size'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a size.'
                      : null,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Shirt', child: Text('Shirt')),
                    DropdownMenuItem(value: 'T-Shirt', child: Text('T-Shirt')),
                    DropdownMenuItem(value: 'Pants', child: Text('Pants')),
                    DropdownMenuItem(value: 'Jacket', child: Text('Jacket')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (Rp)'),
                  validator: (value) {
                    final price = int.tryParse(value?.trim() ?? '');
                    return price == null || price <= 0
                        ? 'Enter a price greater than zero.'
                        : null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  maxLength: 240,
                  decoration: const InputDecoration(labelText: 'Pickup location'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a pickup location.'
                      : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The AI grade and your condition grade are not changed here.',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save changes'),
        ),
      ],
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'brand': _brandController.text.trim(),
      'size': _sizeController.text.trim(),
      'category': _category,
      'price': int.parse(_priceController.text.trim()),
      'description': _descriptionController.text.trim(),
      'pickup_location': _locationController.text.trim(),
    });
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.isBusy,
    required this.onEdit,
    required this.onMarkSold,
    required this.onDelete,
  });

  final ProductModel listing;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onMarkSold;
  final VoidCallback onDelete;

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
                  ? CachedNetworkImage(
                      imageUrl: listing.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _fallbackCover(),
                      errorWidget: (context, url, error) => _fallbackCover(),
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
                    if (!isSold)
                      IconButton(
                        tooltip: 'Mark sold',
                        onPressed: isBusy ? null : onMarkSold,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.check_circle_outline_rounded),
                      ),
                    IconButton(
                      tooltip: 'Edit listing',
                      onPressed: isBusy ? null : onEdit,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete listing',
                      onPressed: isBusy ? null : onDelete,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checkroom_rounded, size: 24, color: Color(0xFF4F7880)),
            Text('No photo', style: TextStyle(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
