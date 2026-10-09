import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _bg = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _darkTeal = Color(0xFF0E3436);
const _cyanSoft = Color(0xFFCFF5FA);
const _line = Color(0xFFE5E3EF);

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _searchController = TextEditingController();
  double _radius = 5;
  RangeValues _price = const RangeValues(0, 150000);
  String _category = 'All';
  String _condition = 'A';
  bool _localPickup = true;
  bool _verified = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: Text(
          'Filter & Refine',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: Text(
              'Reset',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _darkTeal,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          _buildRadiusCard(),
          const SizedBox(height: 12),
          _buildPriceCard(),
          const SizedBox(height: 12),
          _buildCategoryCard(),
          const SizedBox(height: 12),
          _buildConditionCard(),
          const SizedBox(height: 12),
          _buildPreferencesCard(),
        ],
      ),
      bottomSheet: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          color: _bg,
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(FilterResult(
                radius: _radius,
                category: _category,
              )),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                'Show ${_category == 'All' ? '46' : '18'} Results',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by item, brand, or style',
        prefixIcon: const Icon(Icons.search_rounded, color: _muted),
        suffixIcon: IconButton(
          onPressed: () => _searchController.clear(),
          icon: const Icon(Icons.close_rounded, color: _muted),
        ),
        filled: true,
        fillColor: _surface,
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: _darkTeal),
      ),
    );
  }

  Widget _buildRadiusCard() {
    return _section(
      title: 'Search radius',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_radius.round()} km',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(width: 6),
              Text('from current spot', style: _bodyStyle()),
              const Spacer(),
              _pill('Walking & local pickup'),
            ],
          ),
          Slider(
            value: _radius,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: _darkTeal,
            onChanged: (value) => setState(() => _radius = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _caption('1 km'),
              _caption('5 km optimal'),
              _caption('10 km'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Shows preloved drops near Bandung within reachable distance.',
            style: _bodyStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return _section(
      title: 'Price range',
      trailing: 'IDR',
      child: Column(
        children: [
          RangeSlider(
            values: _price,
            min: 0,
            max: 150000,
            divisions: 6,
            activeColor: _darkTeal,
            labels: RangeLabels(
              'Rp ${_price.start.round()}',
              'Rp ${_price.end.round()}',
            ),
            onChanged: (value) => setState(() => _price = value),
          ),
          Row(
            children: [
              _pricePill('Minimum', 'Rp ${_price.start.round()}'),
              const SizedBox(width: 8),
              _pricePill('Maximum', 'Rp ${_price.end.round()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    return _section(
      title: 'Category',
      trailing: _category == 'All' ? 'All items' : '1 selected',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['All', 'Shirt', 'T-Shirt', 'Pants', 'Jacket']
            .map(
              (item) => ChoiceChip(
                label: Text(item),
                selected: _category == item,
                selectedColor: _darkTeal,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: _category == item ? Colors.white : _ink,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => _category = item),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildConditionCard() {
    return _section(
      title: 'Condition',
      trailing: 'AI graded',
      child: Wrap(
        spacing: 8,
        children: ['A', 'B', 'C', 'D']
            .map(
              (item) => ChoiceChip(
                label: Text('Grade $item'),
                selected: _condition == item,
                selectedColor: _cyanSoft,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: _darkTeal,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => setState(() => _condition = item),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return _section(
      title: 'Preferences',
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text('Local pickup only', style: _titleStyle()),
            subtitle:
                Text('Avoid courier transit footprint', style: _bodyStyle()),
            value: _localPickup,
            activeTrackColor: _darkTeal,
            onChanged: (value) => setState(() => _localPickup = value),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text('Verified collectors', style: _titleStyle()),
            subtitle: Text('Authentic garment guarantee', style: _bodyStyle()),
            value: _verified,
            activeTrackColor: _darkTeal,
            onChanged: (value) => setState(() => _verified = value),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
    String? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: _titleStyle()),
              const Spacer(),
              if (trailing != null)
                Text(
                  trailing,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _darkTeal,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _pricePill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F0FB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _captionStyle()),
            Text(value, style: _titleStyle()),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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

  TextStyle _titleStyle() => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _ink,
      );

  TextStyle _bodyStyle() =>
      GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted);

  TextStyle _captionStyle() =>
      GoogleFonts.plusJakartaSans(fontSize: 10, color: _muted);

  Widget _caption(String text) => Text(text, style: _captionStyle());

  InputBorder _border({Color color = Colors.transparent}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color),
      );

  void _reset() {
    setState(() {
      _radius = 5;
      _price = const RangeValues(0, 150000);
      _category = 'All';
      _condition = 'A';
      _localPickup = true;
      _verified = false;
    });
  }
}

class FilterResult {
  const FilterResult({required this.radius, required this.category});

  final double radius;
  final String category;
}
