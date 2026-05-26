import 'package:subscan/features/subscriptions/models/subscription.dart';

/// Interfaz para acceder a datos de suscripciones
/// Implementada por data layer
abstract class SubscriptionRepository {
  /// Obtiene todas las suscripciones del usuario
  Future<List<Subscription>> getSubscriptions();

  /// Obtiene una suscripción por ID
  Future<Subscription?> getSubscriptionById(String id);

  /// Guarda una nueva suscripción
  Future<void> saveSubscription(Subscription subscription);

  /// Actualiza una suscripción existente
  Future<void> updateSubscription(Subscription subscription);

  /// Elimina una suscripción por ID
  Future<void> deleteSubscription(String id);

  /// Sincroniza con Gmail para una cuenta específica.
  /// [accessToken] usa el token guardado (sin UI). [emailHint] para logs.
  Future<List<Subscription>> syncWithGmail({String? accessToken, String? emailHint});
}
