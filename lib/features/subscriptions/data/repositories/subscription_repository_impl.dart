import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:subscan/features/subscriptions/data/datasources/subscription_datasource.dart';
import 'package:subscan/features/subscriptions/data/datasources/gmail_datasource.dart';

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
    // Step 1: deduplicate ALL existing DB entries regardless of Gmail results
    final existing = await datasource.getSubscriptions();
    final existingByName = <String, List<Subscription>>{};
    for (final s in existing) {
      existingByName.putIfAbsent(s.nombre.toLowerCase(), () => []).add(s);
    }
    for (final entries in existingByName.values) {
      if (entries.length > 1) {
        entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        for (final dup in entries.skip(1)) {
          await datasource.deleteSubscription(dup.id);
        }
      }
    }

    // Step 2: fetch Gmail subscriptions
    final gmailDatasource = GmailDatasource();
    final imported = await gmailDatasource.getSubscriptions();
    if (imported.isEmpty) return [];

    // Rebuild map from surviving entries (one per name after dedup)
    final surviving = <String, Subscription>{
      for (final entries in existingByName.values)
        entries.first.nombre.toLowerCase(): entries.first,
    };

    final newOnes = <Subscription>[];

    for (final imp in imported) {
      final key = imp.nombre.toLowerCase();
      final match = surviving[key];

      if (match == null) {
        await datasource.saveSubscription(imp);
        newOnes.add(imp);
      } else if (match.fuente == 'gmail') {
        await datasource.updateSubscription(match.copyWith(
          precioActual: imp.precioActual,
          fechaRenovacion: imp.fechaRenovacion,
          currency: imp.currency,
        ));
      }
    }

    return newOnes;
  }
}
