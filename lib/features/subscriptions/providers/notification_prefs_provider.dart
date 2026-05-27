import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationPrefs {
  final bool recordatorioDiario;
  final bool renovaciones;
  final int diasAnticipacion; // 1, 3 or 7
  final bool alertasPrecio;
  final bool resumenSemanal;

  const NotificationPrefs({
    this.recordatorioDiario = true,
    this.renovaciones = true,
    this.diasAnticipacion = 3,
    this.alertasPrecio = true,
    this.resumenSemanal = false,
  });

  NotificationPrefs copyWith({
    bool? recordatorioDiario,
    bool? renovaciones,
    int? diasAnticipacion,
    bool? alertasPrecio,
    bool? resumenSemanal,
  }) {
    return NotificationPrefs(
      recordatorioDiario: recordatorioDiario ?? this.recordatorioDiario,
      renovaciones: renovaciones ?? this.renovaciones,
      diasAnticipacion: diasAnticipacion ?? this.diasAnticipacion,
      alertasPrecio: alertasPrecio ?? this.alertasPrecio,
      resumenSemanal: resumenSemanal ?? this.resumenSemanal,
    );
  }
}

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier() : super(const NotificationPrefs());

  void setRecordatorioDiario(bool v) =>
      state = state.copyWith(recordatorioDiario: v);

  void setRenovaciones(bool v) =>
      state = state.copyWith(renovaciones: v);

  void setDiasAnticipacion(int v) =>
      state = state.copyWith(diasAnticipacion: v);

  void setAlertasPrecio(bool v) =>
      state = state.copyWith(alertasPrecio: v);

  void setResumenSemanal(bool v) =>
      state = state.copyWith(resumenSemanal: v);
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  (ref) => NotificationPrefsNotifier(),
);
