import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/features/auth/models/linked_account.dart';
import 'package:subscan/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';

/// Estado del UI de suscripciones.
class SubscriptionState {
  final List<Subscription> allSubscriptions;
  final bool isLoading;
  final String? error;
  final String? syncingEmail; // cuenta Gmail sincronizando actualmente

  const SubscriptionState({
    this.allSubscriptions = const [],
    this.isLoading = false,
    this.error,
    this.syncingEmail,
  });

  /// Suscripciones urgentes (≤3 días)
  List<Subscription> get urgentes =>
      allSubscriptions.where((s) => s.isUrgent).toList();

  /// Suscripciones próximas pero no urgentes (4-7 días)
  List<Subscription> get proximas => allSubscriptions
      .where((s) => s.isNearRenewal && !s.isUrgent)
      .toList();

  /// Resto de suscripciones
  List<Subscription> get normales =>
      allSubscriptions.where((s) => !s.isNearRenewal).toList();

  SubscriptionState copyWith({
    List<Subscription>? allSubscriptions,
    bool? isLoading,
    String? error,
    String? syncingEmail,
    bool clearSyncingEmail = false,
  }) {
    return SubscriptionState(
      allSubscriptions: allSubscriptions ?? this.allSubscriptions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      syncingEmail: clearSyncingEmail ? null : (syncingEmail ?? this.syncingEmail),
    );
  }
}

/// Maneja el estado de suscripciones en la UI.
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionNotifier(this._repository)
      : super(const SubscriptionState(isLoading: true)) {
    loadSubscriptions();
  }

  /// Carga todas las suscripciones desde el repositorio.
  Future<void> loadSubscriptions() async {
    state = state.copyWith(isLoading: true);
    try {
      final subscriptions = await _repository.getSubscriptions();
      state = state.copyWith(
        allSubscriptions: subscriptions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Marca una suscripción como renovada (suma 30 días).
  Future<void> renewSubscription(String id) async {
    try {
      final sub = state.allSubscriptions.firstWhere((s) => s.id == id);
      final updated = sub.copyWith(
        fechaRenovacion: DateTime.now().add(const Duration(days: 30)),
      );
      await _repository.updateSubscription(updated);
      final newList = state.allSubscriptions
          .map((s) => s.id == id ? updated : s)
          .toList();
      state = state.copyWith(allSubscriptions: newList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Elimina una suscripción.
  Future<void> deleteSubscription(String id) async {
    try {
      await _repository.deleteSubscription(id);
      final newList = state.allSubscriptions.where((s) => s.id != id).toList();
      state = state.copyWith(allSubscriptions: newList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Agrega una nueva suscripción al repositorio y al estado local.
  Future<void> addSubscription(Subscription subscription) async {
    try {
      await _repository.saveSubscription(subscription);
      final updated = [...state.allSubscriptions, subscription];
      state = state.copyWith(allSubscriptions: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Edita una suscripción existente en el repositorio y en el estado local.
  Future<void> editSubscription(Subscription updated) async {
    try {
      await _repository.updateSubscription(updated);
      final newList = state.allSubscriptions
          .map((s) => s.id == updated.id ? updated : s)
          .toList();
      state = state.copyWith(allSubscriptions: newList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Sincroniza una cuenta Gmail usando su access token guardado.
  /// Devuelve cuántas subs nuevas se encontraron.
  Future<int> syncGmailAccount(LinkedAccount account) async {
    debugPrint('[Sync] Iniciando sync para ${account.email} (token: ${account.accessToken?.isNotEmpty == true ? "OK" : "VACÍO"})');
    try {
      final imported = await _repository.syncWithGmail(
        accessToken: account.accessToken,
        emailHint: account.email,
      );
      debugPrint('[Sync] ${account.email} → ${imported.length} importados');
      final existing = state.allSubscriptions
          .map((s) => s.nombre.toLowerCase())
          .toSet();
      final newOnes = imported
          .where((s) => !existing.contains(s.nombre.toLowerCase()))
          .toList();
      if (newOnes.isNotEmpty) {
        state = state.copyWith(
          allSubscriptions: [...state.allSubscriptions, ...newOnes],
        );
      }
      debugPrint('[Sync] ${account.email} → ${newOnes.length} nuevas subs');
      return newOnes.length;
    } catch (e) {
      debugPrint('[Sync] ERROR en ${account.email}: $e');
      state = state.copyWith(error: e.toString());
      return 0;
    }
  }

  /// Sincroniza todas las cuentas vinculadas EN PARALELO.
  /// Devuelve un mapa email → cantidad de subs nuevas.
  Future<Map<String, int>> syncAllGmailAccounts(
      List<LinkedAccount> accounts) async {
    state = state.copyWith(isLoading: true);
    final futures = accounts.map((a) async {
      final count = await syncGmailAccount(a);
      return MapEntry(a.email, count);
    });
    final entries = await Future.wait(futures);
    final results = Map.fromEntries(entries);
    state = state.copyWith(isLoading: false, clearSyncingEmail: true);
    await loadSubscriptions();
    return results;
  }

  /// Sincroniza suscripciones desde Gmail (cuenta activa, sin token guardado).
  Future<void> syncGmail() async {
    state = state.copyWith(isLoading: true);
    try {
      final imported = await _repository.syncWithGmail();
      final existing = state.allSubscriptions
          .map((s) => s.nombre.toLowerCase())
          .toSet();
      final newOnes = imported
          .where((s) => !existing.contains(s.nombre.toLowerCase()))
          .toList();
      final combined = [...state.allSubscriptions, ...newOnes];
      state = state.copyWith(allSubscriptions: combined, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Limpia el error actual.
  void clearError() => state = state.copyWith(error: null);
}
