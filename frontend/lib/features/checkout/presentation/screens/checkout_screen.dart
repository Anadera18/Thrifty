import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _bg = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _teal = Color(0xFF0E3436);
const _line = Color(0xFFE5E3EF);
const _cyan = Color(0xFFCFF5FA);

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.subtotal,
    required this.itemCount,
  });

  final int subtotal;
  final int itemCount;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'QRIS';
  bool _placingOrder = false;

  @override
  Widget build(BuildContext context) {
    final total = widget.subtotal;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: Text('Checkout', style: _titleStyle(21)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          _sectionCard(
            title: 'Pickup details',
            icon: Icons.location_on_outlined,
            trailing: TextButton(
              onPressed: () => _showMessage('Address editing is coming soon.'),
              child: Text(
                'Edit',
                style: _bodyStyle(11, color: _teal, weight: FontWeight.w800),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_rounded, size: 19, color: _teal),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dinda Putri',
                        style: _bodyStyle(12, weight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Bandung Central · Arrange a public meetup with the seller',
                        style: _bodyStyle(10, color: _muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _sectionCard(
            title: 'Payment method',
            icon: Icons.account_balance_wallet_outlined,
            child: Column(
              children: [
                _paymentOption(
                  'QRIS',
                  'Scan to pay with your e-wallet or bank app',
                  Icons.qr_code_2_rounded,
                ),
                const Divider(height: 1, color: _line),
                _paymentOption(
                  'Bank transfer',
                  'Virtual account transfer',
                  Icons.account_balance_outlined,
                ),
                const Divider(height: 1, color: _line),
                _paymentOption(
                  'Cash at meetup',
                  'Pay the seller when you collect the item',
                  Icons.payments_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _sectionCard(
            title: 'Order summary',
            icon: Icons.receipt_long_outlined,
            child: Column(
              children: [
                _summaryRow(
                  'Items (${widget.itemCount})',
                  _rupiah(widget.subtotal),
                ),
                const SizedBox(height: 9),
                _summaryRow('Pickup', 'Free'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: _line),
                ),
                _summaryRow('Total', _rupiah(total), emphasized: true),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cyan.withValues(alpha: .42),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, size: 18, color: _teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Confirm the item and meetup details with the seller. Payment processing is a demo in this build.',
                    style: _bodyStyle(10, color: _teal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 11, 18, 12),
          decoration: const BoxDecoration(
            color: _surface,
            border: Border(top: BorderSide(color: _line)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL',
                    style: _bodyStyle(
                      9,
                      color: _muted,
                      weight: FontWeight.w800,
                    ),
                  ),
                  Text(_rupiah(total), style: _titleStyle(15)),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton(
                  onPressed: _placingOrder ? null : _placeOrder,
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _placingOrder ? 'Placing order…' : 'Place order',
                    style: _bodyStyle(
                      12,
                      color: Colors.white,
                      weight: FontWeight.w800,
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

  Widget _sectionCard({
    required String title,
    required IconData icon,
    Widget? trailing,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: _line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 17, color: _teal),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                style: _bodyStyle(13, weight: FontWeight.w800),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 11),
        child,
      ],
    ),
  );

  Widget _paymentOption(String name, String detail, IconData icon) {
    final selected = _paymentMethod == name;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = name),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _teal),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: _bodyStyle(11, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(detail, style: _bodyStyle(9, color: _muted)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? _teal : _muted,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasized = false}) =>
      Row(
        children: [
          Text(
            label,
            style: _bodyStyle(
              emphasized ? 12 : 10,
              color: emphasized ? _ink : _muted,
              weight: emphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: _bodyStyle(emphasized ? 13 : 10, weight: FontWeight.w800),
          ),
        ],
      );

  Future<void> _placeOrder() async {
    setState(() => _placingOrder = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _placingOrder = false);
    Navigator.pop(context, _paymentMethod);
  }

  void _showMessage(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}

String _rupiah(int amount) =>
    'Rp ${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
TextStyle _titleStyle(double size) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: FontWeight.w800,
  color: _ink,
);
TextStyle _bodyStyle(
  double size, {
  Color color = _ink,
  FontWeight weight = FontWeight.w500,
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: weight,
  color: color,
);
