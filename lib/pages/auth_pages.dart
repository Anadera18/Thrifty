import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _ink = Color(0xFF12373F);
const _mint = Color(0xFF14B8A6);
const _navy = Color(0xFF0F2942);
const _paper = Color(0xFFF8FAFC);
const _line = Color(0xFFE7EEED);
const _muted = Color(0xFF718582);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _rememberMe = true;

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => _AuthPage(
    child: Column(
      children: [
        const SizedBox(height: 26),
        const _BrandLockup(),
        const SizedBox(height: 27),
        const Text(
          'Preloved fashion, just around the corner',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 14),
        const _Eyebrow('CURATED  •  CIRCULAR  •  ARCHIVAL'),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldTitle('Email address'),
              const SizedBox(height: 7),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration(
                  'Enter your email',
                  Icons.mail_outline_rounded,
                ),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'Enter a valid email address',
              ),
              const SizedBox(height: 16),
              const _FieldTitle('Password'),
              const SizedBox(height: 7),
              TextFormField(
                obscureText: _obscure,
                decoration: _fieldDecoration(
                  'Enter your password',
                  Icons.lock_outline_rounded,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : 'Enter at least 6 characters',
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: Checkbox(
                      value: _rememberMe,
                      visualDensity: VisualDensity.compact,
                      activeColor: _ink,
                      onChanged: (value) =>
                          setState(() => _rememberMe = value ?? false),
                    ),
                  ),
                  const Text(
                    'Remember me',
                    style: TextStyle(fontSize: 11, color: _muted),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        _message(context, 'Password reset is a UI preview.'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _PrimaryButton(label: 'Log In', onPressed: _login),
            ],
          ),
        ),
        const SizedBox(height: 17),
        const _OrDivider(label: 'OR CONTINUE WITH'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Apple',
                icon: Icons.phone_iphone_rounded,
                onPressed: () =>
                    _message(context, 'Apple sign in is a UI preview.'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SocialButton(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
                onPressed: () =>
                    _message(context, 'Google sign in is a UI preview.'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        _SecondaryButton(
          label: 'Create an account',
          icon: Icons.person_add_alt_1_rounded,
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const RegisterPage())),
        ),
        const SizedBox(height: 17),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TrustItem(
              icon: Icons.verified_user_outlined,
              label: 'Verified Sellers',
            ),
            _TrustItem(icon: Icons.recycling_rounded, label: '100% Circular'),
            _TrustItem(
              icon: Icons.local_shipping_outlined,
              label: 'Local Pickup',
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'By continuing, you agree to our ',
              style: TextStyle(fontSize: 9, color: _muted),
            ),
            _FooterLink(
              label: 'Terms of Service',
              onTap: () => _message(context, 'Terms are a UI preview.'),
            ),
            const Text(' and ', style: TextStyle(fontSize: 9, color: _muted)),
            _FooterLink(
              label: 'Privacy Policy',
              onTap: () => _message(context, 'Privacy policy is a UI preview.'),
            ),
            const Text('.', style: TextStyle(fontSize: 9, color: _muted)),
          ],
        ),
        const SizedBox(height: 7),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 11, color: _muted),
            SizedBox(width: 4),
            Text(
              'Encrypted 256-bit authentication',
              style: TextStyle(fontSize: 9, color: _muted),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _accepted = true;
  bool _seller = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (_formKey.currentState!.validate() && _accepted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
        (_) => false,
      );
    } else if (!_accepted) {
      _message(context, 'Please accept the terms to continue.');
    }
  }

  @override
  Widget build(BuildContext context) => _AuthPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 13),
        Row(
          children: [
            _BackButton(onPressed: () => Navigator.of(context).maybePop()),
            const Spacer(),
            const _Eyebrow('ECO  •  CIRCULAR FASHION'),
            const Spacer(),
            const _BrandGlyph(size: 38),
          ],
        ),
        const SizedBox(height: 19),
        Text(
          'Create account',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: _navy, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        const Text(
          'Join the preloved fashion movement',
          style: TextStyle(fontSize: 12, color: _muted),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldTitle('FULL NAME'),
              const SizedBox(height: 5),
              TextFormField(
                decoration: _fieldDecoration(
                  'e.g. Jane Doe',
                  Icons.person_outline_rounded,
                ),
                validator: _required,
              ),
              const SizedBox(height: 11),
              const _FieldTitle('EMAIL ADDRESS'),
              const SizedBox(height: 5),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration(
                  'e.g. jane@example.com',
                  Icons.mail_outline_rounded,
                ),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'Enter a valid email address',
              ),
              const SizedBox(height: 11),
              const _FieldTitle('PASSWORD'),
              const SizedBox(height: 5),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _fieldDecoration(
                  'At least 8 characters',
                  Icons.lock_outline_rounded,
                  suffix: _VisibilityButton(
                    obscure: _obscurePassword,
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) => value != null && value.length >= 8
                    ? null
                    : 'Use at least 8 characters',
              ),
              const SizedBox(height: 11),
              const _FieldTitle('CONFIRM PASSWORD'),
              const SizedBox(height: 5),
              TextFormField(
                obscureText: _obscureConfirmation,
                decoration: _fieldDecoration(
                  'Repeat your password',
                  Icons.lock_reset_rounded,
                  suffix: _VisibilityButton(
                    obscure: _obscureConfirmation,
                    onTap: () => setState(
                      () => _obscureConfirmation = !_obscureConfirmation,
                    ),
                  ),
                ),
                validator: (value) => value == _passwordController.text
                    ? null
                    : 'Passwords do not match',
              ),
              const SizedBox(height: 13),
              const _FieldTitle('PRIMARY ROLE'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      selected: !_seller,
                      icon: Icons.shopping_bag_outlined,
                      title: 'Buyer',
                      subtitle: 'Shop preloved gems nearby',
                      onTap: () => setState(() => _seller = false),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _RoleCard(
                      selected: _seller,
                      icon: Icons.sell_outlined,
                      title: 'Seller',
                      subtitle: 'List & monetize your closet',
                      onTap: () => setState(() => _seller = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _accepted,
                      onChanged: (value) =>
                          setState(() => _accepted = value ?? false),
                      visualDensity: VisualDensity.compact,
                      activeColor: _ink,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy.',
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.35,
                          color: _muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              _PrimaryButton(
                label: 'Create Account',
                onPressed: _createAccount,
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, color: _mint, size: 13),
            SizedBox(width: 5),
            Text(
              '100% Circular  •  Verified Community',
              style: TextStyle(
                fontSize: 10,
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Wrap(
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(fontSize: 11, color: _muted),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 11,
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _sellerMode = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _paper,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          _ProfileTopBar(
            onNotifications: () => _message(context, 'No new notifications.'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              children: [
                _IdentityCard(
                  onEdit: () =>
                      _message(context, 'Profile editing is a UI preview.'),
                ),
                const SizedBox(height: 12),
                const _ImpactCard(),
                const SizedBox(height: 10),
                _SellerModeCard(
                  value: _sellerMode,
                  onChanged: (value) => setState(() => _sellerMode = value),
                ),
                const SizedBox(height: 10),
                const _MetricRow(),
                const SizedBox(height: 10),
                _ProfileMenuTile(
                  icon: Icons.checkroom_outlined,
                  title: 'My Listings',
                  subtitle: '12 active & archived apparel',
                  trailing: '12',
                  onTap: () =>
                      _message(context, 'My Listings is a UI preview.'),
                ),
                _ProfileMenuTile(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Saved items',
                  subtitle: 'Curated wishlist & designer archives',
                  trailing: '18',
                  onTap: () =>
                      _message(context, 'Saved items is a UI preview.'),
                ),
                _ProfileMenuTile(
                  icon: Icons.near_me_outlined,
                  title: 'Location & radius',
                  subtitle: 'Bandung Central • 5 km local loop',
                  onTap: () =>
                      _message(context, 'Location settings are a UI preview.'),
                ),
                _ProfileMenuTile(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Account settings',
                  subtitle: 'Payouts, addresses & security',
                  onTap: () =>
                      _message(context, 'Account settings are a UI preview.'),
                ),
                _ProfileMenuTile(
                  icon: Icons.help_center_outlined,
                  title: 'Help center',
                  subtitle: 'Authentication rules & buyer protection',
                  onTap: () =>
                      _message(context, 'Help center is a UI preview.'),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                    (_) => false,
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 17),
                  label: const Text('Log out'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB14C4C),
                    backgroundColor: const Color(0xFFFFF4F3),
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'THRIFTY V1.0  •  PBL PROTOTYPE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 8,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const _ProfileBottomNav(),
        ],
      ),
    ),
  );
}

class _AuthPage extends StatelessWidget {
  const _AuthPage({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _paper,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _BrandGlyph(size: 72),
      const SizedBox(height: 7),
      Text(
        'THRIFTY',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontFamily: 'Epilogue',
          fontWeight: FontWeight.w800,
          color: _ink,
          letterSpacing: 1.4,
        ),
      ),
    ],
  );
}

class _BrandGlyph extends StatelessWidget {
  const _BrandGlyph({this.size = 42});
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/brand/thrifty_icon.svg',
    width: size,
    height: size,
    semanticsLabel: 'Thrifty logo',
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF5F3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 8,
        letterSpacing: .8,
        color: _ink,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _FieldTitle extends StatelessWidget {
  const _FieldTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      letterSpacing: .45,
      color: _navy,
      fontWeight: FontWeight.w800,
    ),
  );
}

InputDecoration _fieldDecoration(
  String hint,
  IconData icon, {
  Widget? suffix,
}) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9BAAA8)),
  prefixIcon: Icon(icon, size: 17, color: _muted),
  suffixIcon: suffix,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(11),
    borderSide: const BorderSide(color: _line),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(11),
    borderSide: const BorderSide(color: _line),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(11),
    borderSide: const BorderSide(color: _mint, width: 1.3),
  ),
);

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 43,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _ink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 16)],
        ],
      ),
    ),
  );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: _navy, size: 17),
      label: Text(
        label,
        style: const TextStyle(
          color: _navy,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: _line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.zero,
      ),
    ),
  );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 38,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink,
        backgroundColor: Colors.white,
        side: const BorderSide(color: _line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider(color: _line)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 8,
            letterSpacing: .8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const Expanded(child: Divider(color: _line)),
    ],
  );
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 15, color: _ink),
      const SizedBox(height: 3),
      Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          color: _muted,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 9,
        color: _ink,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    icon: const Icon(Icons.arrow_back_rounded, size: 19),
    style: IconButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: _ink,
      side: const BorderSide(color: _line),
      fixedSize: const Size(36, 36),
    ),
  );
}

class _VisibilityButton extends StatelessWidget {
  const _VisibilityButton({required this.obscure, required this.onTap});
  final bool obscure;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    icon: Icon(
      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      size: 16,
      color: _muted,
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(11),
    child: Container(
      constraints: const BoxConstraints(minHeight: 61),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: selected ? _ink : Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: selected ? _ink : _line),
      ),
      child: Row(
        children: [
          Icon(icon, color: selected ? Colors.white : _navy, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : _navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  style: TextStyle(
                    color: selected ? Colors.white70 : _muted,
                    fontSize: 8,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (selected) const Icon(Icons.check_circle, size: 14, color: _mint),
        ],
      ),
    ),
  );
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onNotifications});
  final VoidCallback onNotifications;
  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 17),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: _line)),
    ),
    child: Row(
      children: [
        const _BrandGlyph(size: 20),
        const SizedBox(width: 7),
        const Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Listings',
                style: TextStyle(
                  color: _ink,
                  fontSize: 14,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'THRIFTY ATELIER',
                style: TextStyle(
                  color: _muted,
                  fontSize: 7,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotifications,
          visualDensity: VisualDensity.compact,
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 19,
            color: _navy,
          ),
        ),
        const CircleAvatar(
          radius: 14,
          backgroundColor: _ink,
          child: Text(
            'D',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.onEdit});
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(13, 12, 12, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: _line),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: _ink,
                  child: Text(
                    'DP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified, size: 11, color: _mint),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dinda Putri',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'dinda.putri@atelier.com',
                    style: TextStyle(color: _muted, fontSize: 9),
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 10, color: _mint),
                      Text(
                        ' Bandung Curator',
                        style: TextStyle(color: _muted, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit_outlined, color: _navy, size: 15),
              style: IconButton.styleFrom(
                backgroundColor: _paper,
                fixedSize: const Size(29, 29),
              ),
            ),
          ],
        ),
        const Divider(height: 16, color: _line),
        const Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: _muted, size: 11),
            SizedBox(width: 5),
            Text(
              'Member since Oct 2023',
              style: TextStyle(color: _muted, fontSize: 8),
            ),
            Spacer(),
            Icon(Icons.circle, size: 5, color: _mint),
            SizedBox(width: 4),
            Text(
              'TOP RATED',
              style: TextStyle(
                color: _ink,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_ink, _navy],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.eco_outlined, size: 15, color: _mint),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CIRCULARITY IMPACT  •  Net Positive',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 7,
                  letterSpacing: .65,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '42.4 kg CO₂ averted',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                'Achieved via 8 conscious pre-loved re-homes',
                style: TextStyle(color: Colors.white70, fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SellerModeCard extends StatelessWidget {
  const _SellerModeCard({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7F4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.storefront_outlined, size: 15, color: _mint),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seller mode  ACTIVE',
                style: TextStyle(
                  color: _navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Create listings & AI curation grades',
                style: TextStyle(color: _muted, fontSize: 8),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: _mint,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    ),
  );
}

class _MetricRow extends StatelessWidget {
  const _MetricRow();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _line),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Expanded(
          child: _Metric(value: '12', label: 'LISTINGS'),
        ),
        _MetricDivider(),
        Expanded(
          child: _Metric(value: '8', label: 'SOLD'),
        ),
        _MetricDivider(),
        Expanded(
          child: _Metric(value: '5 KM', label: 'RADIUS'),
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: _navy,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(
          color: _muted,
          fontSize: 7,
          letterSpacing: .7,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 25, width: 1, color: _line);
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: _line),
    ),
    child: ListTile(
      onTap: onTap,
      dense: true,
      minLeadingWidth: 28,
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      leading: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F6F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _ink, size: 15),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: _navy,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: _muted, fontSize: 7),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5F3),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                trailing!,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const Icon(Icons.chevron_right_rounded, size: 17, color: _muted),
        ],
      ),
    ),
  );
}

class _ProfileBottomNav extends StatelessWidget {
  const _ProfileBottomNav();
  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _line)),
    ),
    child: const SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: _NavItem(icon: Icons.home_outlined, label: 'Home'),
          ),
          Expanded(
            child: _NavItem(icon: Icons.search_rounded, label: 'Search'),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.add_circle_rounded,
              label: 'Add',
              prominent: true,
            ),
          ),
          Expanded(
            child: _NavItem(icon: Icons.sell_outlined, label: 'Listings'),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              selected: true,
            ),
          ),
        ],
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.prominent = false,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final bool prominent;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
        size: prominent ? 25 : 18,
        color: prominent
            ? _ink
            : selected
            ? _mint
            : _muted,
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(
          color: selected ? _ink : _muted,
          fontSize: 7,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    ],
  );
}

String? _required(String? value) =>
    value != null && value.trim().isNotEmpty ? null : 'This field is required';

void _message(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
