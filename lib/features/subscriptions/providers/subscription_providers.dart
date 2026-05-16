import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:subscan/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:subscan/features/subscriptions/data/datasources/subscription_datasource.dart';
import 'package:subscan/core/services/subscription_service.dart';

/// Provider para el datasource de suscripciones
/// Persona 3 implementará: SupabaseDatasource, GmailDatasource
final subscriptionDatasourceProvider = Provider<SubscriptionDatasource>((ref) {
  // TODO: Implementar datasource concreto (Firebase/Supabase)
  throw UnimplementedError(
    'SubscriptionDatasource debe ser implementado por Persona 3',
  );
});

/// Provider para el repositorio de suscripciones
/// Inyecta el datasource y expone métodos CRUD
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final datasource = ref.watch(subscriptionDatasourceProvider);
  return SubscriptionRepositoryImpl(datasource: datasource);
});

/// Provider para el servicio de distribución de datos en estructuras
/// Acceso a métodos estáticos para cargar y consultar suscripciones
final subscriptionServiceProvider = Provider((ref) {
  return SubscriptionDataStructureService;
});
