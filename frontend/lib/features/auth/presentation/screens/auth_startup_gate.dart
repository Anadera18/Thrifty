import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_auth_service.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../onboarding/presentation/screens/welcome_flow.dart';
import '../providers/auth_state_providers.dart';

class AuthStartupGate extends ConsumerWidget {
  const AuthStartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.isLoading) return const _StartupLoadingScreen();
    if (authState.hasError &&
        Supabase.instance.client.auth.currentSession == null) {
      return _StartupErrorScreen(
        message: 'We could not check your sign-in status. Check your '
            'connection and try again.',
        onRetry: () => ref.invalidate(authStateProvider),
      );
    }

    final user = ref.watch(currentSupabaseUserProvider);
    if (user == null) return const ThriftySplashScreen();

    final profile = ref.watch(currentSupabaseProfileProvider);
    return profile.when(
      loading: () => const _StartupLoadingScreen(),
      error: (_, __) => _StartupErrorScreen(
        message: 'We could not load your account profile. Check your '
            'connection and try again.',
        onRetry: () => ref.invalidate(currentSupabaseProfileProvider),
      ),
      data: (row) {
        final role = row?['role'];
        final displayName = row?['display_name'];
        if (row == null ||
            (role != 'buyer' && role != 'seller') ||
            displayName is! String ||
            displayName.trim().isEmpty) {
          return const _MissingProfileScreen();
        }
        return const HomeScreen();
      },
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissingProfileScreen extends StatelessWidget {
  const _MissingProfileScreen();

  Future<void> _signOut(BuildContext context) async {
    try {
      await SupabaseAuthService().signOut();
    } on AuthException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Please try again.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This account is signed in, but its THRIFTY profile is missing '
                'or incomplete. Please contact the project team.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _signOut(context),
                child: const Text('Sign out and continue as guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
