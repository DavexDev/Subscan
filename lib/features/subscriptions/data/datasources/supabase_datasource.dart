import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/data/datasources/subscription_datasource.dart';

class SupabaseSubscriptionDatasource implements SubscriptionDatasource {
  final SupabaseClient _client = Supabase.instance.client;
  static const _table = 'subscriptions';

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final response = await _client
        .from(_table)
        .select()
        .order('fecha_renovacion', ascending: true);

    return (response as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    await _client.from(_table).insert(_toRow(subscription));
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await _client
        .from(_table)
        .update(_toRow(subscription))
        .eq('id', subscription.id);
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Subscription _fromRow(Map<String, dynamic> row) {
    return Subscription(
      id: row['id'] as String,
      nombre: row['nombre'] as String,
      precioActual: (row['precio_actual'] as num).toDouble(),
      precioOriginal: row['precio_original'] != null
          ? (row['precio_original'] as num).toDouble()
          : null,
      fechaRenovacion: DateTime.parse(row['fecha_renovacion'] as String),
      fuente: row['fuente'] as String? ?? 'manual',
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Map<String, dynamic> _toRow(Subscription s) {
    return {
      'id': s.id,
      'nombre': s.nombre,
      'precio_actual': s.precioActual,
      'precio_original': s.precioOriginal,
      'fecha_renovacion': s.fechaRenovacion.toIso8601String(),
      'fuente': s.fuente,
    };
  }
}
