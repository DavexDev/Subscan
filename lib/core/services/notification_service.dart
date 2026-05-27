import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/providers/notification_prefs_provider.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'poda_renovaciones';
  static const _channelName = 'Renovaciones PODA';
  static const _dailyChannelId = 'poda_diario';
  static const _kDailyId = 999;

  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      // Derive IANA timezone from system UTC offset (Etc/GMT uses inverted sign)
      final offsetHours = DateTime.now().timeZoneOffset.inHours;
      final tzName = offsetHours == 0
          ? 'UTC'
          : 'Etc/GMT${(-offsetHours) > 0 ? '+' : ''}${-offsetHours}';
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Fallback to UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<bool> hasPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return (await android?.areNotificationsEnabled()) ?? false;
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return (await android?.requestNotificationsPermission()) ?? false;
  }

  static Future<void> _scheduleDailyReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 12, 20, 0);
    // If 12:15 already passed today, first fire is tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      _kDailyId,
      '¿Ya revisaste tus suscripciones?',
      'Mantén el control de tus gastos fijos.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyChannelId,
          'Recordatorio diario',
          channelDescription: 'Recordatorio diario de PODA',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<int> scheduleAll(
    List<Subscription> subs,
    NotificationPrefs prefs,
  ) async {
    await _plugin.cancelAll();

    if (prefs.recordatorioDiario) await _scheduleDailyReminder();
    if (!prefs.renovaciones) return 0;

    final nowTz = tz.TZDateTime.now(tz.local);
    int id = 1000;
    int scheduled = 0;

    for (final sub in subs) {
      final notifyDay = sub.fechaRenovacion
          .subtract(Duration(days: prefs.diasAnticipacion));

      final scheduledTime = tz.TZDateTime(
        tz.local,
        notifyDay.year,
        notifyDay.month,
        notifyDay.day,
        12, 20, 0,
      );

      if (scheduledTime.isBefore(nowTz)) continue;

      final dias = prefs.diasAnticipacion;
      final diasStr = dias == 1 ? '1 día antes' : '$dias días antes';

      await _plugin.zonedSchedule(
        id++,
        'Renovación: ${sub.nombre}',
        'Se renueva en $diasStr · ${sub.precioFormateado}/mes',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Avisos de renovación de suscripciones PODA',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      scheduled++;
    }

    return scheduled;
  }

  // Keep for backward compatibility — delegates to scheduleAll
  static Future<int> scheduleRenewalNotifications(
    List<Subscription> subs,
    NotificationPrefs prefs,
  ) => scheduleAll(subs, prefs);

  static Future<void> showTestNotification() async {
    await _plugin.show(
      0,
      '¡Notificaciones funcionando! ✓',
      'PODA puede enviarte recordatorios diarios.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyChannelId,
          'Recordatorio diario',
          channelDescription: 'Recordatorio diario de PODA',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
