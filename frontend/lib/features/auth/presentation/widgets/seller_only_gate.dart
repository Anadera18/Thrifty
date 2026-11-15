import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_state_providers.dart';
import '../screens/login_screen.dart';

class SellerOnlyGate extends ConsumerWidget {
  const SellerOnlyGate({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentSupabaseUserProvider);
    if (user == null) {
      return _AccessMessage(
        title: 'Please log in to continue',
        message: 'Sign in to your seller account and this page will open here.',
        actionLabel: 'Log in',
        onPressed: () {
          Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(returnToCaller: true),
            ),
          );
        },
      );
    }

    final profile = ref.watch(currentSupabaseProfileProvider);
    return profile.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _AccessMessage(
        title: 'Could not verify your account',
        message: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onPressed: () => ref.invalidate(currentSupabaseProfileProvider),
      ),
      data: (row) {
        if (row?['role'] == 'seller') return child;
        return _AccessMessage(
          title: 'Seller account required',
          message: 'This feature is available only to seller accounts.',
          actionLabel: 'Go back',
          onPressed: () => Navigator.of(context).maybePop(),
        );
      },
    );
  }
}

class _AccessMessage extends StatelessWidget {
  const _AccessMessage({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onPressed, child: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
