import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _bg = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _teal = Color(0xFF0E3436);
const _green = Color(0xFF14532D);
const _line = Color(0xFFE5E3EF);
const _cyan = Color(0xFFCFF5FA);

class ProductDetailsData {
  const ProductDetailsData({
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

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    this.product = const ProductDetailsData(
      name: 'Vintage Denim Jacket',
      brand: 'Thrifty Archive',
      price: 'Rp 89.000',
      distance: '1.2 km',
      rating: '4.9',
      grade: 'Grade A • Like New',
      placeholderColor: Color(0xFFD9E8EA),
      iconColor: Color(0xFF4F7880),
      icon: Icons.checkroom_rounded,
    ),
    this.onAddToCart,
  });

  final ProductDetailsData product;
  final VoidCallback? onAddToCart;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 310,
            backgroundColor: _bg,
            elevation: 0,
            leading: _roundAction(
              Icons.arrow_back_rounded,
              () => Navigator.pop(context),
            ),
            actions: [
              _roundAction(
                _saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                () => setState(() => _saved = !_saved),
                color: _saved ? const Color(0xFFDC2626) : _teal,
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: product.placeholderColor,
                    child: Center(
                      child: Icon(
                        product.icon,
                        size: 112,
                        color: product.iconColor,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 18,
                    child: _pill(
                      Icons.verified_rounded,
                      'CONDITION CHECKED',
                      _teal,
                      Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: _pill(
                      Icons.location_on_outlined,
                      product.distance,
                      Colors.white,
                      _teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 17, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.brand.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .7,
                            color: _teal,
                          ),
                        ),
                      ),
                      const Icon(Icons.star_rounded, size: 16, color: _green),
                      const SizedBox(width: 3),
                      Text(
                        product.rating,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(product.name, style: _titleStyle(23)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        product.price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F3E8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Preloved',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _gradeCard(product.grade),
                  const SizedBox(height: 17),
                  _sectionTitle('About this item'),
                  const SizedBox(height: 7),
                  Text(
                    '${product.name} from ${product.brand}. A carefully selected preloved piece with a clear condition grade, ready for its next owner.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.6,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoCard([
                    _infoRow(
                      Icons.checkroom_outlined,
                      'Condition',
                      product.grade.replaceFirst('Grade ', ''),
                    ),
                    const Divider(height: 18, color: _line),
                    _infoRow(
                      Icons.local_shipping_outlined,
                      'Delivery',
                      'Local pickup available',
                    ),
                    const Divider(height: 18, color: _line),
                    _infoRow(
                      Icons.location_on_outlined,
                      'Distance',
                      product.distance,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _sellerCard(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFF4E6C3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF9A6700),
                          size: 19,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Keep your chat and payment on Thrifty. Meet in a public place and check the item before completing your exchange.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              height: 1.5,
                              color: const Color(0xFF775719),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 11, 18, 12),
          decoration: BoxDecoration(
            color: _surface,
            border: const Border(top: BorderSide(color: _line)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      widget.onAddToCart ??
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart (demo).')),
                      ),
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: Text(
                    'Add to cart',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _teal,
                    side: const BorderSide(color: _teal),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat with seller is coming soon.'),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Chat with seller',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundAction(
    IconData icon,
    VoidCallback onTap, {
    Color color = _teal,
  }) => Padding(
    padding: const EdgeInsets.only(left: 10),
    child: Material(
      color: Colors.white.withValues(alpha: .95),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
        visualDensity: VisualDensity.compact,
      ),
    ),
  );

  Widget _pill(
    IconData icon,
    String label,
    Color background,
    Color foreground,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: foreground),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
      ],
    ),
  );

  Widget _gradeCard(String grade) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _cyan.withValues(alpha: .38),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _cyan),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: _teal, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Thrifty condition grade',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _teal,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                grade,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Review the photos and description with the seller at pickup to confirm the item matches its listing.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            height: 1.5,
            color: _muted,
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Text(
    title,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: _ink,
    ),
  );

  Widget _infoCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Column(children: children),
  );

  Widget _infoRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 17, color: _teal),
      const SizedBox(width: 9),
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _muted),
      ),
      const Spacer(),
      Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
    ],
  );

  Widget _sellerCard() => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 21,
          backgroundColor: _teal,
          child: Text(
            'DP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dinda Putri',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Trusted local seller • 4.9 rating',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _muted),
              ),
            ],
          ),
        ),
        const Icon(Icons.verified_rounded, color: _green, size: 19),
      ],
    ),
  );
}

TextStyle _titleStyle(double size) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: FontWeight.w800,
  color: _ink,
);
