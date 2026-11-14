import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../home/presentation/screens/location_onboarding_screen.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../widgets/thrifty_logo.dart';
import 'register_screen.dart';

const _bg = Color(0xFFFBF9FF);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _fieldBg = Color(0xFFF2F0FB);
const _hint = Color(0xFFB9B7CF);
const _green = Color(0xFF14532D);
const _line = Color(0xFFE5E3EF);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.returnToCaller = false});

  final bool returnToCaller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = SupabaseAuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
        ),
      );
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    var loginSucceeded = false;
    try {
      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null || response.session == null) {
        _showLoginError('We could not start a session. Please try again.');
      } else {
        final profile = await _authService.getProfile(user.id);
        final role = profile?['role'];
        final displayName = profile?['display_name'];
        if (profile == null ||
            (role != 'buyer' && role != 'seller') ||
            displayName is! String ||
            displayName.trim().isEmpty) {
          await _authService.signOut();
          _showLoginError(
            'Your account profile is missing or incomplete. Please contact '
            'the project team.',
          );
        } else {
          loginSucceeded = true;
        }
      }
    } on AuthRetryableFetchException {
      _showLoginError(
        'Could not reach Supabase. Check your internet connection and try again.',
      );
    } on AuthApiException catch (error) {
      _showLoginError(_loginErrorMessage(error.code));
      debugPrint('Supabase login failed with code: ${error.code ?? 'none'}');
    } on AuthException {
      _showLoginError('We could not sign you in. Please try again.');
    } catch (error) {
      _showLoginError('We could not complete sign-in. Check your connection.');
      debugPrint('Supabase login failed with ${error.runtimeType}.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!loginSucceeded || !mounted) return;
    if (widget.returnToCaller) {
      Navigator.of(context).pop(true);
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LocationOnboardingScreen(),
      ),
    );
  }

  String _loginErrorMessage(String? code) {
    switch (code) {
      case 'invalid_credentials':
      case 'user_not_found':
        return 'Email or password is incorrect.';
      case 'over_request_rate_limit':
        return 'Too many sign-in attempts. Wait a few minutes and try again.';
      case 'user_banned':
        return 'This account is temporarily unavailable. Contact the project team.';
      default:
        return 'We could not sign you in. Please check your details and try again.';
    }
  }

  void _showLoginError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildFormCard(),
                  const SizedBox(height: 16),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader() {
    return Column(
      children: [
        const ThriftyLogo(size: 64),
        const SizedBox(height: 10),
        Text(
          'THRIFTY',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: _ink,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 220,
          child: Text(
            'Preloved fashion, just around the corner',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.35,
              color: _muted,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Form card ----------
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Email address'),
          const SizedBox(height: 8),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _ink),
            decoration: _inputDecoration(
              hint: 'hello@thrifty.app',
              icon: Icons.mail_outline_rounded,
            ),
          ),
          const SizedBox(height: 18),
          _label('Password'),
          const SizedBox(height: 8),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _ink),
            decoration: _inputDecoration(
              hint: '••••••••••••',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password reset is not available in this prototype yet.',
                    ),
                  ),
                );
              },
              child: Text(
                'Forgot password?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Log In',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(child: Divider(color: _line, height: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: const Color(0xFF8A8CA0),
                  ),
                ),
              ),
              const Expanded(child: Divider(color: _line, height: 1)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _ink,
                side: const BorderSide(color: Color(0xFFDAD8E6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Create an account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: _ink,
    ),
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: _hint),
      filled: true,
      fillColor: _fieldBg,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _green, width: 1.2),
      ),
    );
  }

  // ---------- Footer ----------
  Widget _buildFooter() {
    final base = GoogleFonts.plusJakartaSans(
      fontSize: 10.5,
      height: 1.6,
      color: const Color(0xFF4B5563),
    );
    final link = base.copyWith(
      fontWeight: FontWeight.w700,
      color: _ink,
      decoration: TextDecoration.underline,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            const TextSpan(text: 'By signing in, you agree to our '),
            TextSpan(text: 'Terms of Service', style: link),
            const TextSpan(text: ' and '),
            TextSpan(text: 'Privacy Policy', style: link),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
