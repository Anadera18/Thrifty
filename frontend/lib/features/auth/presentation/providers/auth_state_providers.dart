import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_auth_service.dart';

final supabaseAuthServiceProvider = Provider<SupabaseAuthService>(
  (ref) => SupabaseAuthService(),
);

final authStateProvider = StreamProvider<AuthState>((ref) {
  final controller = StreamController<AuthState>();
  final subscription = ref
      .read(supabaseAuthServiceProvider)
      .authStateChanges
      .listen(
    controller.add,
    onError: (Object error, StackTrace stackTrace) {
      controller.addError(error, stackTrace);
    },
  );

  ref.onDispose(() {
    unawaited(() async {
      await subscription.cancel();
      await controller.close();
    }());
  });

  return controller.stream;
});

final currentSupabaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  final service = ref.read(supabaseAuthServiceProvider);

  return authState.when(
    data: (state) => state.session?.user,
    loading: () => service.currentUser,
    error: (_, __) => service.currentUser,
  );
});

final currentSupabaseProfileProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentSupabaseUserProvider);
  if (user == null) return null;

  return ref.read(supabaseAuthServiceProvider).getProfile(user.id);
});

final currentSupabaseRoleProvider = Provider<String?>((ref) {
  final profile = ref.watch(currentSupabaseProfileProvider);
  return profile.when(
    data: (row) {
      final role = row?['role'];
      if (role == 'buyer' || role == 'seller') return role as String;
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
