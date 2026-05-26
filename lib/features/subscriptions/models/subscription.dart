/// Model para una suscripción
class Subscription {
  final String id;
  final String nombre;
  final double precioActual;
  final double? precioOriginal;
  final DateTime fechaRenovacion;
  final String fuente;
  final String currency; // 'GTQ', 'USD', 'EUR', 'MXN', 'GBP'
  final DateTime createdAt;
  final String? emailCuenta; // cuenta Gmail que originó esta suscripción

  Subscription({
    required this.id,
    required this.nombre,
    required this.precioActual,
    this.precioOriginal,
    required this.fechaRenovacion,
    this.fuente = 'manual',
    this.currency = 'GTQ',
    DateTime? createdAt,
    this.emailCuenta,
  }) : createdAt = createdAt ?? DateTime.now();

  String get currencySymbol {
    switch (currency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'MXN': return 'MX\$';
      case 'GBP': return '£';
      default: return 'Q';
    }
  }

  String get precioFormateado =>
      '$currencySymbol${precioActual.toStringAsFixed(2)}';

  /// Días restantes hasta renovación (negativo = ya venció)
  int get diasRestantes {
    return fechaRenovacion.difference(DateTime.now()).inDays;
  }

  /// ¿Ya venció? (fecha de renovación en el pasado)
  bool get isVencida => diasRestantes < 0;

  /// ¿Es urgente? (0–3 días, sin incluir vencidas)
  bool get isUrgent => diasRestantes >= 0 && diasRestantes <= 3;

  /// ¿Está próximo a renovarse? (0–7 días, sin incluir vencidas)
  bool get isNearRenewal => diasRestantes >= 0 && diasRestantes <= 7;

  /// Retorna copia con cambios
  Subscription copyWith({
    String? id,
    String? nombre,
    double? precioActual,
    double? precioOriginal,
    DateTime? fechaRenovacion,
    String? fuente,
    String? currency,
    DateTime? createdAt,
    String? emailCuenta,
  }) {
    return Subscription(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precioActual: precioActual ?? this.precioActual,
      precioOriginal: precioOriginal ?? this.precioOriginal,
      fechaRenovacion: fechaRenovacion ?? this.fechaRenovacion,
      fuente: fuente ?? this.fuente,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      emailCuenta: emailCuenta ?? this.emailCuenta,
    );
  }

  @override
  String toString() =>
      'Subscription(id: $id, nombre: $nombre, precio: \$$precioActual, renovación: $fechaRenovacion)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subscription &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
