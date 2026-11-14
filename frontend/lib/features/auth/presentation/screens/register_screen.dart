import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_auth_service.dart';
import '../../../home/presentation/screens/location_onboarding_screen.dart';

const _bg = Color(0xFFFBF9FF);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF5B6270);
const _fieldBg = Color(0xFFF2F0FB);
const _green = Color(0xFF14532D);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _selectedRole;
  bool _roleError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_isLoading) return;

    final formIsValid = _formKey.currentState?.validate() ?? false;
    if (!formIsValid) return;

    if (_selectedRole == null) {
      setState(() => _roleError = true);
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please agree to the Terms of Service and Privacy Policy.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    var registered = false;
    try {
      final response = await SupabaseAuthService().registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        role: _selectedRole!,
      );

      if (response.user == null || response.session == null) {
        _showRegistrationError(
          'Account creation did not start a session. Check that Confirm email '
          'is turned off in the THRIFTY Supabase project.',
        );
      } else {
        registered = true;
      }
    } on AuthWeakPasswordException {
      _showRegistrationError(
        'Choose a stronger password that meets the project requirements.',
      );
    } on AuthRetryableFetchException {
      _showRegistrationError(
        'Could not reach Supabase. Check your internet connection and try again.',
      );
    } on AuthApiException catch (error) {
      _showRegistrationError(_authApiErrorMessage(error.code));
      debugPrint('Supabase signup failed with code: ${error.code ?? 'none'}');
    } on AuthException {
      _showRegistrationError(
        'We could not create your account. Please try again.',
      );
    } catch (error) {
      _showRegistrationError(
        'We could not create your account. Please try again.',
      );
      debugPrint('Supabase signup failed with ${error.runtimeType}.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!registered || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully.'),
        backgroundColor: _green,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LocationOnboardingScreen()),
    );
  }

  String _authApiErrorMessage(String? code) {
    switch (code) {
      case 'user_already_exists':
      case 'email_exists':
        return 'An account with this email already exists. Try logging in.';
      case 'email_address_invalid':
        return 'Enter a valid email address.';
      case 'weak_password':
        return 'Choose a stronger password that meets the project requirements.';
      case 'email_provider_disabled':
      case 'signup_disabled':
        return 'Email registration is unavailable for this project right now.';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Too many attempts. Wait a few minutes and try again.';
      default:
        return 'We could not create your account. Please try again.';
    }
  }

  void _showRegistrationError(String message) {
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildFormCard(),
                  const SizedBox(height: 16),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Create account',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Start buying and selling preloved items',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: _muted,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Full Name'),
            const SizedBox(height: 5),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              style: _inputTextStyle(),
              decoration: _inputDecoration(
                hint: 'e.g. Clara Dupont',
                icon: Icons.person_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _label('Email address'),
            const SizedBox(height: 5),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              style: _inputTextStyle(),
              decoration: _inputDecoration(
                hint: 'clara@example.com',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Enter your email address';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _label('Password'),
            const SizedBox(height: 5),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.next,
              style: _inputTextStyle(),
              decoration: _inputDecoration(
                hint: 'At least 8 characters',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  tooltip: _hidePassword ? 'Show password' : 'Hide password',
                  onPressed: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                    color: _muted,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter a password';
                if (value.length < 8) return 'Use at least 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _label('Confirm password'),
            const SizedBox(height: 5),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _hideConfirmPassword,
              textInputAction: TextInputAction.done,
              style: _inputTextStyle(),
              decoration: _inputDecoration(
                hint: 'Repeat your password',
                icon: Icons.lock_reset_rounded,
                suffix: IconButton(
                  tooltip:
                      _hideConfirmPassword ? 'Show password' : 'Hide password',
                  onPressed: () {
                    setState(() {
                      _hideConfirmPassword = !_hideConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _hideConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                    color: _muted,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onFieldSubmitted: (_) => _createAccount(),
            ),
            const SizedBox(height: 14),
            _label('I want to'),
            const SizedBox(height: 5),
            Text(
              'Choose how you will use THRIFTY. You can browse as a buyer or list items as a seller.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.4,
                color: _muted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildRoleChoice(
                    role: 'buyer',
                    title: 'Buyer',
                    description: 'Find and purchase items',
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRoleChoice(
                    role: 'seller',
                    title: 'Seller',
                    description: 'List items for sale',
                    icon: Icons.sell_outlined,
                  ),
                ),
              ],
            ),
            if (_roleError) ...[
              const SizedBox(height: 5),
              Text(
                'Choose Buyer or Seller to continue.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFFB42318),
                ),
              ),
            ],
            const SizedBox(height: 5),
            Text(
              'This prototype does not let you change this choice later.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: _muted,
              ),
            ),
            const SizedBox(height: 14),
            _buildTermsCheckbox(),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                            'Create Account',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChoice({
    required String role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final selected = _selectedRole == role;
    return Semantics(
      button: true,
      selected: selected,
      label: '$title: $description',
      child: InkWell(
        onTap: _isLoading
            ? null
            : () => setState(() {
                  _selectedRole = role;
                  _roleError = false;
                }),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF3EC) : _fieldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? _green
                  : _roleError
                      ? const Color(0xFFD64545)
                      : Colors.transparent,
              width: selected || _roleError ? 1.2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? _green : _muted),
              const SizedBox(height: 5),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return InkWell(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _agreedToTerms,
              onChanged: (value) {
                setState(() => _agreedToTerms = value ?? false);
              },
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: Color(0xFF9AA0AA)),
              activeColor: _green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  height: 1.45,
                  color: _muted,
                ),
                children: const [
                  TextSpan(text: "I agree to THRIFTY's "),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: Color(0xFF075C7A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF075C7A),
                      decoration: TextDecoration.underline,
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

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF075C7A),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Already have an account? ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: _muted,
              ),
            ),
            TextSpan(
              text: 'Login',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF075C7A),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    );
  }

  TextStyle _inputTextStyle() {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      color: _ink,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: const Color(0xFF8A91A2),
      ),
      prefixIcon: Icon(icon, size: 17, color: const Color(0xFF65758B)),
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB5C5ED), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD64545)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD64545), width: 1.2),
      ),
    );
  }
}
