import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/screens/login_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../my_listings/presentation/screens/my_listings_screen.dart';
import '../../../product_detail/presentation/screens/product_detail.dart';
import '../../../saved_items/presentation/screens/saved_items_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../help_center/presentation/screens/help_center_screen.dart';
import '../state/account_mode_store.dart';

const _bg = Color(0xFFFBF9FF);
const _surface = Colors.white;
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _green = Color(0xFF14532D);
const _darkTeal = Color(0xFF0E3436);
const _cyanSoft = Color(0xFFCFF5FA);
const _line = Color(0xFFE5E3EF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    AccountModeStore.isSeller.addListener(_refresh);
    SavedProductsStore.items.addListener(_refresh);
  }

  @override
  void dispose() {
    AccountModeStore.isSeller.removeListener(_refresh);
    SavedProductsStore.items.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isSeller = AccountModeStore.isSeller.value;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _goHome(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: () => _goHome(context),
            icon: const Icon(Icons.home_outlined, color: _ink),
          ),
        ],
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: Column(
          children: [
            _buildIdentityCard(context, isSeller),
            const SizedBox(height: 14),
            _buildStatsRow(isSeller),
            const SizedBox(height: 14),
            _buildAccountModeCard(context, isSeller),
            const SizedBox(height: 14),
            _buildMenuCard(context, isSeller),
            const SizedBox(height: 16),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(BuildContext context, bool isSeller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: _darkTeal,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'DP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dinda Putri',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    Text(
                      'dinda.putri@atelier.com',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _cyanSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isSeller ? 'Seller account' : 'Buyer account',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _darkTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showMessage(
                  context,
                  'Profile editing will be available soon.',
                ),
                borderRadius: BorderRadius.circular(24),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFF2F0FB),
                  child: Icon(Icons.edit_outlined, color: _darkTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Member since Oct 2023',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted),
              ),
              if (isSeller) ...[
                const Spacer(),
                Text(
                  'TOP RATED',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _green,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isSeller) {
    if (!isSeller) {
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '${SavedProductsStore.items.value.length}',
              label: 'SAVED ITEMS',
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: _StatCard(value: '5 KM', label: 'RADIUS'),
          ),
        ],
      );
    }
    return const Row(
      children: [
        Expanded(
          child: _StatCard(value: '12', label: 'LISTINGS'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(value: '8', label: 'SOLD'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(value: '5 KM', label: 'RADIUS'),
        ),
      ],
    );
  }

  Widget _buildAccountModeCard(
    BuildContext context,
    bool isSeller,
  ) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _cyanSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isSeller ? Icons.storefront_outlined : Icons.shopping_bag_outlined,
            color: _darkTeal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account mode',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isSeller ? 'Seller tools are enabled' : 'Shopping as a buyer',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _muted),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            AccountModeStore.toggle();
            _showMessage(
              context,
              isSeller
                  ? 'Switched to buyer account.'
                  : 'Switched to seller account.',
            );
          },
          child: Text(
            isSeller ? 'Switch to buyer' : 'Switch to seller',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _darkTeal,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildMenuCard(BuildContext context, bool isSeller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          if (isSeller) ...[
            _MenuTile(
              icon: Icons.inventory_2_outlined,
              title: 'My listings',
              subtitle: '12 active & archived apparel',
              trailing: '12',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyListingsScreen()),
              ),
            ),
            const _MenuDivider(),
          ],
          _MenuTile(
            icon: Icons.bookmark_outline_rounded,
            title: 'Saved items',
            subtitle: 'Your favorite thrift finds',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SavedItemsScreen())),
          ),
          const _MenuDivider(),
          _MenuTile(
            icon: Icons.location_on_outlined,
            title: 'Location & radius',
            subtitle: 'Bandung Central • 5 km loop',
            onTap: () =>
                _showMessage(context, 'Location radius is set to 5 km.'),
          ),
          const _MenuDivider(),
          _MenuTile(
            icon: Icons.settings_outlined,
            title: 'Account settings',
            subtitle: 'Payouts, addresses & security',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const _MenuDivider(),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Help center',
            subtitle: 'Authentication rules & buyer protection',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        ),
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFB91C1C)),
        label: Text(
          'Logout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFB91C1C),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF3D4D4)),
          backgroundColor: const Color(0xFFFFF4F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _goHome(BuildContext context) {
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _darkTeal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _muted,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F0FB),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _darkTeal),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _muted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _cyanSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                trailing!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _darkTeal,
                ),
              ),
            ),
          const SizedBox(width: 5),
          const Icon(Icons.chevron_right_rounded, size: 24, color: _muted),
        ],
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: _line);
  }
}
