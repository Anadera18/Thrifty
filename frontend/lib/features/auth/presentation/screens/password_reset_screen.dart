import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _resetBg = Color(0xFFFBF9FF);
const _resetInk = Color(0xFF111827);
const _resetMuted = Color(0xFF5B6270);
const _resetGreen = Color(0xFF14532D);
const _resetLine = Color(0xFFE5E3EF);

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _resetBg,
      appBar: AppBar(
        backgroundColor: _resetBg,
        foregroundColor: _resetInk,
        elevation: 0,
        title: Text(
          'Reset password',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _resetLine),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_reset_rounded,
                      size: 38,
                      color: _resetGreen,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Forgot your password?',
                      style: GoogleFonts.plusJakartaSans(
                        color: _resetInk,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your account email to continue. Password recovery is not connected in this prototype.',
                      style: GoogleFonts.plusJakartaSans(
                        color: _resetMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Email address',
                      style: GoogleFonts.plusJakartaSans(
                        color: _resetInk,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'hello@thrifty.app',
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF2F0FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _resetGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (_submitted) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF2D18A)),
                        ),
                        child: Text(
                          'Password reset is not available in this prototype. No email was sent.',
                          style: GoogleFonts.plusJakartaSans(
                            color: _resetInk,
                            fontSize: 12,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
