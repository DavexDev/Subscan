/// Model para una suscripción
class Subscription {
  final String id;
  final String nombre;
  final double precioActual;
  final double? precioOriginal;
  final DateTime fechaRenovacion;
  final String fuente;
  final DateTime createdAt;

  Subscription({
    required this.id,
    required this.nombre,
    required this.precioActual,
    this.precioOriginal,
    required this.fechaRenovacion,
    this.fuente = 'manual',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Días restantes hasta renovación
  int get diasRestantes {
    return fechaRenovacion.difference(DateTime.now()).inDays;
  }

  /// ¿Es urgente? (menos de 3 días)
  bool get isUrgent => diasRestantes <= 3;

  /// ¿Está próximo a renovarse? (menos de 7 días)
  bool get isNearRenewal => diasRestantes <= 7;

  /// Retorna copia con cambios
  Subscription copyWith({
    String? id,
    String? nombre,
    double? precioActual,
    double? precioOriginal,
    DateTime? fechaRenovacion,
    String? fuente,
    DateTime? createdAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precioActual: precioActual ?? this.precioActual,
      precioOriginal: precioOriginal ?? this.precioOriginal,
      fechaRenovacion: fechaRenovacion ?? this.fechaRenovacion,
      fuente: fuente ?? this.fuente,
      createdAt: createdAt ?? this.createdAt,
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
