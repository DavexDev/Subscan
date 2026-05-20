import 'package:subscan/features/subscriptions/data/datasources/subscription_datasource.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';

/// Datasource temporal con datos de demostración.
/// Se reemplaza con la implementación real de Supabase/Gmail cuando esté lista.
class MockSubscriptionDatasource implements SubscriptionDatasource {
  // Lista mutable en memoria para simular CRUD
  final List<Subscription> _data = [
    Subscription(
      id: '1',
      nombre: 'Netflix',
      precioActual: 15.99,
      precioOriginal: 15.99,
      fechaRenovacion: DateTime.now().add(const Duration(days: 2)),
      fuente: 'manual',
    ),
    Subscription(
      id: '2',
      nombre: 'Spotify',
      precioActual: 10.99,
      precioOriginal: 9.99,
      fechaRenovacion: DateTime.now().add(const Duration(days: 1)),
      fuente: 'manual',
    ),
    Subscription(
      id: '3',
      nombre: 'Disney+',
      precioActual: 8.99,
      precioOriginal: 8.99,
      fechaRenovacion: DateTime.now().add(const Duration(days: 6)),
      fuente: 'gmail',
    ),
    Subscription(
      id: '4',
      nombre: 'Adobe Creative Cloud',
      precioActual: 54.99,
      precioOriginal: 54.99,
      fechaRenovacion: DateTime.now().add(const Duration(days: 14)),
      fuente: 'gmail',
    ),
    Subscription(
      id: '5',
      nombre: 'Microsoft 365',
      precioActual: 6.99,
      precioOriginal: 6.99,
      fechaRenovacion: DateTime.now().add(const Duration(days: 22)),
      fuente: 'manual',
    ),
    Subscription(
      id: '6',
      nombre: 'YouTube Premium',
      precioActual: 13.99,
      precioOriginal: 11.99,
      fechaRenovacion: DateTime.now().add(const Duration(days: 3)),
      fuente: 'gmail',
    ),
  ];

  @override
  Future<List<Subscription>> getSubscriptions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_data);
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _data.add(subscription);
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _data.indexWhere((s) => s.id == subscription.id);
    if (index != -1) {
      _data[index] = subscription;
    }
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _data.removeWhere((s) => s.id == id);
  }
}
