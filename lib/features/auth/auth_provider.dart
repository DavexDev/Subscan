import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/features/auth/auth_service.dart';

/// Instancia singleton del AuthService.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Estado actual del usuario autenticado (null = no autenticado).
final currentUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

/// Stream de cambios de sesión — útil para escuchar login/logout.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
