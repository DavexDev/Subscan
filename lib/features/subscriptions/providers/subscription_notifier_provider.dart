import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/features/subscriptions/presentation/notifiers/subscription_notifier.dart';
import 'package:subscan/features/subscriptions/providers/subscription_providers.dart';

/// Provider del notifier de suscripciones.
final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionNotifier(repository);
});
