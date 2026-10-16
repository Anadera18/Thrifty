import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _bg = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _teal = Color(0xFF0E3436);
const _line = Color(0xFFE5E3EF);
const _cyan = Color(0xFFCFF5FA);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'All';
  final _items = <_Notice>[
    _Notice(
      Icons.local_offer_outlined,
      'A new drop near you',
      'Vintage finds were just listed within 2 km of Bandung Central.',
      '12 min ago',
      true,
      _teal,
    ),
    _Notice(
      Icons.verified_outlined,
      'Your listing is live',
      'Washed Denim Jacket is now visible to nearby shoppers.',
      'Yesterday',
      true,
      const Color(0xFF14532D),
    ),
    _Notice(
      Icons.favorite_border_rounded,
      'Someone saved your item',
      'Your Heavyweight Boxy Tee is on a new wishlist.',
      'Yesterday',
      false,
      const Color(0xFFB45309),
    ),
    _Notice(
      Icons.security_outlined,
      'A quick safety reminder',
      'Keep conversations and payments on Thrifty for a safer exchange.',
      'Oct 12',
      false,
      const Color(0xFF5B6270),
    ),
  ];

  List<_Notice> get _visible => _filter == 'Unread'
      ? _items.where((item) => !item.read).toList()
      : _items;

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((item) => !item.read).length;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: Text('Notifications', style: _titleStyle(21)),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _teal,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'ALL UPDATES',
                    '${_items.length}',
                    Icons.notifications_none_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'UNREAD',
                    '$unread',
                    Icons.mark_email_unread_outlined,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                for (final label in ['All', 'Unread']) _filterChip(label),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _visible.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 2, 18, 24),
                    itemCount: _visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 9),
                    itemBuilder: (context, index) =>
                        _noticeCard(_visible[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: _cyan.withValues(alpha: .6),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: _teal),
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: _titleStyle(17)),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
                color: _muted,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _filterChip(String label) {
    final selected = _filter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = label),
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

  Widget _noticeCard(_Notice item) => Material(
    color: item.read ? _surface : const Color(0xFFF1FAFB),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: () => setState(() => item.read = true),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(item.icon, color: item.color, size: 21),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                      ),
                      if (!item.read)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: _teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      height: 1.45,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.time,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: _cyan,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.done_all_rounded, size: 34, color: _teal),
          ),
          const SizedBox(height: 14),
          Text('You’re all caught up', style: _titleStyle(16)),
          const SizedBox(height: 5),
          Text(
            'No unread notifications right now.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted),
          ),
        ],
      ),
    ),
  );

  void _markAllRead() => setState(() {
    for (final item in _items) {
      item.read = true;
    }
  });
}

class _Notice {
  _Notice(
    this.icon,
    this.title,
    this.message,
    this.time,
    this.read,
    this.color,
  );
  final IconData icon;
  final String title;
  final String message;
  final String time;
  bool read;
  final Color color;
}

TextStyle _titleStyle(double size) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: FontWeight.w800,
  color: _ink,
);
