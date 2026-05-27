import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethod {
  final String id;
  final String tipo;
  final String? alias;

  const PaymentMethod({required this.id, required this.tipo, this.alias});

  String get displayName =>
      (alias != null && alias!.isNotEmpty) ? alias! : tipo;
}

class PaymentMethodsNotifier extends StateNotifier<List<PaymentMethod>> {
  PaymentMethodsNotifier() : super([]);

  void add(String tipo, String? alias) {
    final trimmed = alias?.trim();
    state = [
      ...state,
      PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tipo: tipo,
        alias: (trimmed != null && trimmed.isNotEmpty) ? trimmed : null,
      ),
    ];
  }

  void remove(String id) {
    state = state.where((m) => m.id != id).toList();
  }
}

final paymentMethodsProvider =
    StateNotifierProvider<PaymentMethodsNotifier, List<PaymentMethod>>(
  (ref) => PaymentMethodsNotifier(),
);
