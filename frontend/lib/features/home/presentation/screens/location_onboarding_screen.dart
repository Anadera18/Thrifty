import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

import '../../../auth/presentation/widgets/thrifty_logo.dart';
import '../widgets/location_radar.dart';
import 'home_screen.dart';

const _bg = Color(0xFFFBF9FF);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF4B5563);
const _cyanSoft = Color(0xFFCFF5FA);
const _teal = Color(0xFF0E7490);
const _darkTeal = Color(0xFF0E3436);
const _green = Color(0xFF065F0B);

class LocationOnboardingScreen extends StatelessWidget {
  const LocationOnboardingScreen({super.key});

  Future<void> _onAllowLocation(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Continuing without location.'),
        ),
      );
    } else {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    }

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      children: [
                        const _DiscoverChip(),
                        const SizedBox(height: 22),
                        const LocationRadar(size: 190),
                        const SizedBox(height: 34),
                        Text(
                          'Find thrift near you',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            'Enable location to browse preloved treasures, '
                            'vintage gems, and circular sellers right in your '
                            'neighborhood. Pick up locally and reduce shipping '
                            'emissions.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              height: 1.45,
                              color: _muted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const _FeatureCard(
                          icon: Icons.location_on_outlined,
                          title: 'Neighborhood Sellers',
                          subtitle:
                              'Connect with vetted curators within walking distance',
                        ),
                        const SizedBox(height: 10),
                        const _FeatureCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Zero-Emissions Local Pickup',
                          subtitle:
                              'Skip box waste and high parcel delivery rates',
                        ),
                        const SizedBox(height: 10),
                        const _FeatureCard(
                          icon: Icons.bolt_outlined,
                          title: 'Real-time Deal Alerts',
                          subtitle:
                              'Instant notifications when rare archive pieces arrive',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Pinned bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _onAllowLocation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.navigation_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Allow location access',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFCFF),
        border: Border(bottom: BorderSide(color: Color(0xFFEEECF6))),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_rounded, size: 22, color: _ink),
            ),
          ),
          const SizedBox(width: 6),
          const ThriftyLogo(size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'LOCATION\nONBOARDING',
              maxLines: 2,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: _ink,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: _darkTeal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                size: 18, color: Color(0xFFE0FFF8)),
          ),
        ],
      ),
    );
  }
}

class _DiscoverChip extends StatelessWidget {
  const _DiscoverChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _cyanSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_rounded, size: 13, color: Color(0xFF0E4B52)),
          const SizedBox(width: 6),
          Text(
            'DISCOVER NEARBY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: const Color(0xFF0E4B52),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: _cyanSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: _teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}