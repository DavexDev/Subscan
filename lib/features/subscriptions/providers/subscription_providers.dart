import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:subscan/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:subscan/features/subscriptions/data/datasources/subscription_datasource.dart';
import 'package:subscan/features/subscriptions/data/datasources/mock_datasource.dart';
import 'package:subscan/core/services/subscription_service.dart';

/// Datasource activo. Cambiar a SupabaseDatasource cuando esté disponible.
final subscriptionDatasourceProvider = Provider<SubscriptionDatasource>((ref) {
  return MockSubscriptionDatasource();
});

/// Repositorio que expone los métodos CRUD inyectando el datasource.
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final datasource = ref.watch(subscriptionDatasourceProvider);
  return SubscriptionRepositoryImpl(datasource: datasource);
});

/// Servicio de distribución en estructuras de datos.
final subscriptionServiceProvider = Provider((ref) {
  return SubscriptionDataStructureService;
});
