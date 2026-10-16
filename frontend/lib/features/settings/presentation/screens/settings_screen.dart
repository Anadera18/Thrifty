import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _bg = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _teal = Color(0xFF0E3436);
const _line = Color(0xFFE5E3EF);
const _cyan = Color(0xFFCFF5FA);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _nearbyDrops = true;
  bool _priceAlerts = false;
  String _pickupPreference = 'Meet in public';

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
        title: Text('Settings', style: _titleStyle(21)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _introCard(),
          const SizedBox(height: 18),
          _sectionLabel('PREFERENCES'),
          const SizedBox(height: 9),
          _card([
            _switchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Push notifications',
              subtitle: 'Get updates about your account and orders',
              value: _pushNotifications,
              onChanged: (value) => setState(() => _pushNotifications = value),
            ),
            _divider(),
            _switchTile(
              icon: Icons.location_on_outlined,
              title: 'Nearby drops',
              subtitle: 'Be the first to know about local finds',
              value: _nearbyDrops,
              onChanged: (value) => setState(() => _nearbyDrops = value),
            ),
            _divider(),
            _switchTile(
              icon: Icons.sell_outlined,
              title: 'Price alerts',
              subtitle: 'Know when saved items change price',
              value: _priceAlerts,
              onChanged: (value) => setState(() => _priceAlerts = value),
            ),
          ]),
          const SizedBox(height: 18),
          _sectionLabel('BUYING & PICKUP'),
          const SizedBox(height: 9),
          _card([
            _tapTile(
              icon: Icons.handshake_outlined,
              title: 'Pickup preference',
              subtitle: _pickupPreference,
              onTap: _choosePickup,
            ),
            _divider(),
            _tapTile(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy & security',
              subtitle: 'Manage your account protection',
              onTap: () => _showMessage('Your account is protected.'),
            ),
          ]),
          const SizedBox(height: 18),
          _sectionLabel('ABOUT'),
          const SizedBox(height: 9),
          _card([
            _tapTile(
              icon: Icons.info_outline_rounded,
              title: 'About Thrifty',
              subtitle: 'Version 1.0.0',
              onTap: () =>
                  _showMessage('Thrifty — good finds, given a second life.'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _introCard() => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: _teal,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .14),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.tune_rounded, color: Colors.white),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Make Thrifty yours',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Choose what you want to see and hear about.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: .78),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: .8,
      color: _muted,
    ),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _line),
    ),
    child: Column(children: children),
  );

  Widget _divider() => const Padding(
    padding: EdgeInsets.only(left: 58),
    child: Divider(height: 1, color: _line),
  );

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(13, 8, 10, 8),
    child: Row(
      children: [
        _iconBox(icon),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _bodyStyle(13, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: _bodyStyle(11, color: _muted)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: _teal,
        ),
      ],
    ),
  );

  Widget _tapTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
    leading: _iconBox(icon),
    title: Text(title, style: _bodyStyle(13, weight: FontWeight.w700)),
    subtitle: Text(subtitle, style: _bodyStyle(11, color: _muted)),
    trailing: const Icon(Icons.chevron_right_rounded, color: _muted),
  );

  Widget _iconBox(IconData icon) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: _cyan.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(icon, color: _teal, size: 19),
  );

  Future<void> _choosePickup() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Text('Pickup preference', style: _titleStyle(18)),
              const SizedBox(height: 8),
              for (final option in [
                'Meet in public',
                'Contactless pickup',
                'Flexible',
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    option == _pickupPreference
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: option == _pickupPreference ? _teal : _muted,
                  ),
                  title: Text(
                    option,
                    style: _bodyStyle(13, weight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context, option),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) setState(() => _pickupPreference = selected);
  }

  void _showMessage(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}

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
