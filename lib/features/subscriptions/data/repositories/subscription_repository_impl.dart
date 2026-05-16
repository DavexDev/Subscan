import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:subscan/features/subscriptions/data/datasources/subscription_datasource.dart';

/// Implementación concreta del SubscriptionRepository
/// Usa un datasource (Supabase, Firebase, etc)
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionDatasource datasource;

  SubscriptionRepositoryImpl({required this.datasource});

  @override
  Future<List<Subscription>> getSubscriptions() async {
    return await datasource.getSubscriptions();
  }

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    final subscriptions = await datasource.getSubscriptions();
    try {
      return subscriptions.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    return await datasource.saveSubscription(subscription);
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    return await datasource.updateSubscription(subscription);
  }

  @override
  Future<void> deleteSubscription(String id) async {
    return await datasource.deleteSubscription(id);
  }

  @override
  Future<List<Subscription>> syncWithGmail() async {
    // Placeholder: Persona 3 implementará esto
    // Llamará a Edge Function de Supabase
    throw UnimplementedError('Persona 3 implementará Gmail sync');
  }
}
