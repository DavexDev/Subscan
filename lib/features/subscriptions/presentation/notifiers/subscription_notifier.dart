import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';

/// Estado del UI de suscripciones.
class SubscriptionState {
  final List<Subscription> allSubscriptions;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.allSubscriptions = const [],
    this.isLoading = false,
    this.error,
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
  }) {
    return SubscriptionState(
      allSubscriptions: allSubscriptions ?? this.allSubscriptions,
      isLoading: isLoading ?? this.isLoading,
      error: error,  // null limpia el error anterior intencionalmente
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

  /// Limpia el error actual.
  void clearError() => state = state.copyWith(error: null);
}
