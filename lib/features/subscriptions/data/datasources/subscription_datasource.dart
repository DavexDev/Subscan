import 'package:subscan/features/subscriptions/models/subscription.dart';

/// Interfaz abstracta para datasources de suscripciones
/// Persona 3 implementará: SupabaseDatasource, GmailDatasource
abstract class SubscriptionDatasource {
  /// Obtiene suscripciones de la fuente
  Future<List<Subscription>> getSubscriptions();

  /// Guarda suscripción en la fuente
  Future<void> saveSubscription(Subscription subscription);

  /// Actualiza suscripción en la fuente
  Future<void> updateSubscription(Subscription subscription);

  /// Elimina suscripción de la fuente
  Future<void> deleteSubscription(String id);
}
