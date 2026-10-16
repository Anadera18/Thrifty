import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/widgets/thrifty_logo.dart';
import '../../../home/presentation/screens/home_screen.dart';

const _forest = Color(0xFF14532D);
const _paper = Color(0xFFF7F3E8);
const _ink = Color(0xFF202820);
const _muted = Color(0xFF74776E);
const _clay = Color(0xFFC87955);

class ThriftySplashScreen extends StatefulWidget {
  const ThriftySplashScreen({super.key});

  @override
  State<ThriftySplashScreen> createState() => _ThriftySplashScreenState();
}

class _ThriftySplashScreenState extends State<ThriftySplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ThriftyLogo(size: 84),
            const SizedBox(height: 18),
            Text(
              'thrifty',
              style: GoogleFonts.plusJakartaSans(
                color: _forest,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'good finds, close by',
              style: GoogleFonts.plusJakartaSans(color: _muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  static const _pages = [
    _WelcomePage(
      eyebrow: 'WELCOME TO THRIFTY',
      title: 'Good finds,\nclose to home.',
      description: 'Discover pre-loved clothes from people and small sellers around your neighborhood.',
      icon: Icons.location_on_outlined,
      accent: Color(0xFFDCE8D5),
      label: 'Your neighborhood, new-to-you style',
    ),
    _WelcomePage(
      eyebrow: 'SHOP WITH A STORY',
      title: 'Give good clothes\nanother go.',
      description: 'Find pieces with a little history, at prices that feel right for everyday life.',
      icon: Icons.checkroom_outlined,
      accent: Color(0xFFF1DFD2),
      label: 'Pre-loved pieces, picked by people',
    ),
    _WelcomePage(
      eyebrow: 'PASS IT ON',
      title: 'Your wardrobe\nhas another story.',
      description: 'List the clothes you no longer wear and help someone nearby find their next favorite.',
      icon: Icons.recycling_outlined,
      accent: Color(0xFFE5E1C9),
      label: 'Wear more. Waste a little less.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _browseAsGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _openLogin();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: Row(
                children: [
                  const ThriftyLogo(size: 38),
                  const SizedBox(width: 9),
                  Text(
                    'thrifty',
                    style: GoogleFonts.plusJakartaSans(
                      color: _forest,
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _openLogin,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.plusJakartaSans(color: _muted),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) =>
                    _WelcomeSlide(page: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _page ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: index == _page
                              ? _forest
                              : const Color(0xFFD4D2C8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _forest,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isLastPage ? 'Continue to login' : 'Next',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _browseAsGuest,
                    child: Text(
                      'Browse as a guest',
                      style: GoogleFonts.plusJakartaSans(
                        color: _forest,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage {
  const _WelcomePage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.label,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final String label;
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({required this.page});

  final _WelcomePage page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationHeight = (constraints.maxHeight * 0.44)
            .clamp(220.0, 330.0)
            .toDouble();
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: illustrationHeight,
                width: double.infinity,
                child: _WelcomeIllustration(page: page),
              ),
              const SizedBox(height: 26),
              Text(
                page.eyebrow,
                style: GoogleFonts.plusJakartaSans(
                  color: _clay,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                page.title,
                style: GoogleFonts.plusJakartaSans(
                  color: _ink,
                  fontSize: 34,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                page.description,
                style: GoogleFonts.plusJakartaSans(
                  color: _muted,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration({required this.page});

  final _WelcomePage page;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 248,
          height: 248,
          decoration: BoxDecoration(color: page.accent, shape: BoxShape.circle),
        ),
        Positioned(
          left: 8,
          top: 42,
          child: Transform.rotate(
            angle: -0.1,
            child: _MiniCard(
              icon: Icons.checkroom_outlined,
              title: 'Pre-loved',
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 42,
          child: Transform.rotate(
            angle: 0.08,
            child: _MiniCard(
              icon: Icons.location_on_outlined,
              title: 'Near you',
              color: Colors.white,
            ),
          ),
        ),
        Container(
          width: 116,
          height: 116,
          decoration: const BoxDecoration(
            color: _forest,
            shape: BoxShape.circle,
          ),
          child: Icon(page.icon, color: _paper, size: 54),
        ),
        Positioned(
          right: 58,
          top: 38,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _clay,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 16),
          ),
        ),
        Positioned(
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              page.label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _forest, size: 18),
          const SizedBox(width: 7),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
