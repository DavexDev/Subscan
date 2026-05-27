import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/data/datasources/subscription_datasource.dart';

class SupabaseSubscriptionDatasource implements SubscriptionDatasource {
  final SupabaseClient _client = Supabase.instance.client;
  static const _table = 'subscriptions';

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No hay sesión activa');
    return uid;
  }

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', _uid)
        .order('fecha_renovacion', ascending: true);

    return (response as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    await _client.from(_table).insert(_toRow(subscription, includeId: false));
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await _client
        .from(_table)
        .update(_toRow(subscription, includeId: false))
        .eq('id', subscription.id)
        .eq('user_id', _uid);
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await _client.from(_table).delete().eq('id', id).eq('user_id', _uid);
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
      currency: row['currency'] as String? ?? 'GTQ',
      createdAt: DateTime.parse(row['created_at'] as String),
      emailCuenta: row['email_cuenta'] as String?,
      metodoPago: row['metodo_pago'] as String?,
    );
  }

  Map<String, dynamic> _toRow(Subscription s, {bool includeId = true}) {
    return {
      if (includeId) 'id': s.id,
      'user_id': _uid,
      'nombre': s.nombre,
      'precio_actual': s.precioActual,
      'precio_original': s.precioOriginal,
      'fecha_renovacion': s.fechaRenovacion.toIso8601String(),
      'fuente': s.fuente,
      'currency': s.currency,
      'email_cuenta': s.emailCuenta,
      'metodo_pago': s.metodoPago,
    };
  }
}
