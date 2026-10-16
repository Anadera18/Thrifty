import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _bg = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _teal = Color(0xFF0E3436);
const _line = Color(0xFFE5E3EF);
const _cyan = Color(0xFFCFF5FA);

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchController = TextEditingController();
  String _category = 'Popular';

  static const _faqs = <_Faq>[
    _Faq(
      'Popular',
      'How does Thrifty verify item condition?',
      'Sellers share item details and condition photos. Our grading guide helps you understand wear before you arrange a pickup.',
    ),
    _Faq(
      'Popular',
      'How do I arrange a local pickup?',
      'Open a listing, contact the seller through Thrifty, and agree on a public pickup spot and time before confirming.',
    ),
    _Faq(
      'Buying',
      'Can I return an item after pickup?',
      'Preloved items are usually final sale. Review photos and details carefully, and confirm the item together at pickup.',
    ),
    _Faq(
      'Buying',
      'How do I keep a transaction safe?',
      'Keep messages on Thrifty, meet in a public place, inspect the item before paying, and never share verification codes.',
    ),
    _Faq(
      'Selling',
      'How do I make my listing easier to find?',
      'Use clear photos, an accurate condition grade, a helpful description, and a fair price for your item.',
    ),
    _Faq(
      'Selling',
      'Can I edit or remove a listing?',
      'Yes. Open My Listings from your profile to update details or archive an item that is no longer available.',
    ),
    _Faq(
      'Account',
      'How do I change my location radius?',
      'Open your profile and choose Location & radius to update the area used for nearby recommendations.',
    ),
  ];

  List<_Faq> get _visibleFaqs {
    final query = _searchController.text.trim().toLowerCase();
    return _faqs
        .where(
          (faq) =>
              (_category == 'Popular'
                  ? faq.category == 'Popular'
                  : faq.category == _category) &&
              (query.isEmpty ||
                  faq.question.toLowerCase().contains(query) ||
                  faq.answer.toLowerCase().contains(query)),
        )
        .toList();
  }

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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: Text('Help center', style: _titleStyle(21)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          _searchBox(),
          const SizedBox(height: 15),
          SizedBox(
            height: 37,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final category in [
                  'Popular',
                  'Buying',
                  'Selling',
                  'Account',
                ])
                  _categoryChip(category),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _category == 'Popular'
                ? 'Frequently asked'
                : '$_category questions',
            style: _titleStyle(16),
          ),
          const SizedBox(height: 9),
          if (_visibleFaqs.isEmpty)
            _noResults()
          else
            ..._visibleFaqs.map(_faqTile),
          const SizedBox(height: 18),
          _contactCard(),
        ],
      ),
    );
  }

  Widget _heroCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _teal,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We’re here to help',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Find quick answers about buying, selling, and meeting safely.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: .78),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .13),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    ),
  );

  Widget _searchBox() => TextField(
    controller: _searchController,
    onChanged: (_) => setState(() {}),
    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _ink),
    decoration: InputDecoration(
      hintText: 'Search for an answer...',
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted),
      prefixIcon: const Icon(Icons.search_rounded, color: _muted),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _teal),
      ),
    ),
  );

  Widget _categoryChip(String category) {
    final selected = _category == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: selected,
        onSelected: (_) => setState(() => _category = category),
        backgroundColor: _surface,
        selectedColor: _cyan,
        side: BorderSide(color: selected ? _cyan : _line),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _teal,
        ),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  Widget _faqTile(_Faq faq) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: _line),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 1),
        childrenPadding: const EdgeInsets.fromLTRB(13, 0, 13, 14),
        iconColor: _teal,
        collapsedIconColor: _muted,
        title: Text(
          faq.question,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              faq.answer,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.55,
                color: _muted,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _noResults() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: _line),
    ),
    child: Center(
      child: Text(
        'No articles found. Try another search.',
        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted),
      ),
    ),
  );

  Widget _contactCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _cyan.withValues(alpha: .6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: _teal,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Still need a hand?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Our support team can help you out.',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _muted),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Support chat is coming soon.')),
          ),
          child: Text(
            'Contact',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _teal,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Faq {
  const _Faq(this.category, this.question, this.answer);
  final String category;
  final String question;
  final String answer;
}

TextStyle _titleStyle(double size) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: FontWeight.w800,
  color: _ink,
);
