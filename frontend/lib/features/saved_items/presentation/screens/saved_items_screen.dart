import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../product_detail/presentation/screens/product_detail.dart';

const _bg = Color(0xFFFBF9FF);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _teal = Color(0xFF0E3436);
const _line = Color(0xFFE5E3EF);

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: Text(
          'Saved items',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<ProductDetailsData>>(
        valueListenable: SavedProductsStore.items,
        builder: (context, products, _) {
          if (products.isEmpty) return _emptyState();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _savedCard(context, products[index]),
          );
        },
      ),
    );
  }

  Widget _savedCard(BuildContext context, ProductDetailsData product) =>
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: product,
                onAddToCart: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Open Home to add this item to your cart.'),
                  ),
                ),
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _line),
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 78,
                  decoration: BoxDecoration(
                    color: product.placeholderColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(product.icon, size: 30, color: product.iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .5,
                          color: _teal,
                        ),
                      ),
                      const SizedBox(height: 3),
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
                      const SizedBox(height: 5),
                      Text(
                        product.price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      Text(
                        product.grade,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove from saved items',
                  onPressed: () => SavedProductsStore.toggle(product),
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: Color(0xFFCFF5FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 34,
              color: _teal,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Your loved items live here',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Tap the heart on a product to save it for later.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted),
          ),
        ],
      ),
    ),
  );
}
