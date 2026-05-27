import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/services/notification_service.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/providers/notification_prefs_provider.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kAccent = Color(0xFF4F6BFF);

class NotificacionesPage extends ConsumerStatefulWidget {
  const NotificacionesPage({super.key});

  @override
  ConsumerState<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends ConsumerState<NotificacionesPage>
    with WidgetsBindingObserver {
  bool? _hasPermission; // null = cargando
  int _scheduledCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Rechecks permission when user returns from system settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final granted = await NotificationService.hasPermission();
    if (!mounted) return;
    setState(() => _hasPermission = granted);
    if (granted) await _reschedule();
  }

  Future<void> _requestPermission() async {
    final granted = await NotificationService.requestPermission();
    if (!mounted) return;
    setState(() => _hasPermission = granted);
    if (granted) await _reschedule();
  }

  Future<void> _reschedule() async {
    final prefs = ref.read(notificationPrefsProvider);
    final subs = ref.read(subscriptionNotifierProvider).allSubscriptions;
    final count = await NotificationService.scheduleRenewalNotifications(subs, prefs);
    if (mounted) setState(() => _scheduledCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);

    // Reschedule when prefs or subscriptions change
    ref.listen(notificationPrefsProvider, (_, __) {
      if (_hasPermission == true) _reschedule();
    });
    ref.listen(subscriptionNotifierProvider, (_, __) {
      if (_hasPermission == true) _reschedule();
    });

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 20,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.s16),
        children: [
          // ── Preferencias ────────────────────────────────────────────────────
          _SectionLabel('PREFERENCIAS'),
          const SizedBox(height: DesignTokens.s8),
          Container(
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(DesignTokens.rL),
            ),
            child: Column(
              children: [
                _ToggleRow(
                  icon: Icons.event_repeat_rounded,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Renovaciones próximas',
                  subtitle: 'Avisa antes de que se renueve una suscripción',
                  value: prefs.renovaciones,
                  onChanged: notifier.setRenovaciones,
                ),
                AnimatedSize(
                  duration: DesignTokens.animNormal,
                  curve: Curves.easeInOut,
                  child: prefs.renovaciones
                      ? _DaysSelector(
                          selected: prefs.diasAnticipacion,
                          onSelect: notifier.setDiasAnticipacion,
                        )
                      : const SizedBox.shrink(),
                ),
                _Divider(),
                _ToggleRow(
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Aumentos de precio',
                  subtitle: 'Cuando una suscripción suba de tarifa',
                  value: prefs.alertasPrecio,
                  onChanged: notifier.setAlertasPrecio,
                ),
                _Divider(),
                _ToggleRow(
                  icon: Icons.summarize_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Resumen semanal',
                  subtitle: 'Un resumen de tus gastos cada semana',
                  value: prefs.resumenSemanal,
                  onChanged: notifier.setResumenSemanal,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.s24),

          // ── Notificaciones del sistema ────────────────────────────────────
          _SectionLabel('NOTIFICACIONES DEL SISTEMA'),
          const SizedBox(height: DesignTokens.s8),
          _PermissionCard(
            hasPermission: _hasPermission,
            scheduledCount: _scheduledCount,
            prefs: prefs,
            subs: ref.watch(subscriptionNotifierProvider).allSubscriptions,
            onRequestPermission: _requestPermission,
          ),
        ],
      ),
    );
  }
}

// ─── Permission card ──────────────────────────────────────────────────────────

class _PermissionCard extends StatelessWidget {
  final bool? hasPermission;
  final int scheduledCount;
  final NotificationPrefs prefs;
  final List<Subscription> subs;
  final VoidCallback onRequestPermission;

  const _PermissionCard({
    required this.hasPermission,
    required this.scheduledCount,
    required this.prefs,
    required this.subs,
    required this.onRequestPermission,
  });

  String _nextLabel() {
    if (!prefs.renovaciones || subs.isEmpty) return 'Sin renovaciones activas';
    final now = DateTime.now();
    DateTime? earliest;
    String? name;
    for (final s in subs) {
      final d = s.fechaRenovacion.subtract(Duration(days: prefs.diasAnticipacion));
      if (d.isAfter(now) && (earliest == null || d.isBefore(earliest))) {
        earliest = d;
        name = s.nombre;
      }
    }
    if (earliest == null) return 'Sin próximas renovaciones';
    final diff = earliest.difference(now).inDays;
    if (diff == 0) return 'Hoy · $name';
    if (diff == 1) return 'Mañana · $name';
    return 'En $diff días · $name';
  }

  @override
  Widget build(BuildContext context) {
    // Loading
    if (hasPermission == null) {
      return Container(
        padding: const EdgeInsets.all(DesignTokens.s20),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(DesignTokens.rL),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: _kAccent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Permission denied
    if (hasPermission == false) {
      return Container(
        padding: const EdgeInsets.all(DesignTokens.s20),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(DesignTokens.rL),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: DesignTokens.s12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permiso no concedido',
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 15,
                          fontWeight: DesignTokens.wSemibold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Activa las notificaciones para recibir avisos en la bandeja',
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 12,
                          color: Colors.white54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.s16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onRequestPermission,
                icon: const Icon(Icons.notifications_active_rounded, size: 18),
                label: const Text(
                  'Activar notificaciones',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 14,
                    fontWeight: DesignTokens.wSemibold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.rM),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Permission granted
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(
          color: DesignTokens.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignTokens.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: DesignTokens.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: DesignTokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Notificaciones activas',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 15,
                            fontWeight: DesignTokens.wSemibold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.s8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: DesignTokens.success.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(DesignTokens.rFull),
                          ),
                          child: Text(
                            '$scheduledCount programadas',
                            style: TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 10,
                              fontWeight: DesignTokens.wSemibold,
                              color: DesignTokens.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recibirás avisos directamente en la bandeja',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (prefs.renovaciones && scheduledCount > 0) ...[
            const SizedBox(height: DesignTokens.s16),
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            const SizedBox(height: DesignTokens.s12),
            _InfoRow(
              icon: Icons.schedule_rounded,
              label: 'Próxima alerta',
              value: _nextLabel(),
            ),
            const SizedBox(height: DesignTokens.s8),
            _InfoRow(
              icon: Icons.alarm_rounded,
              label: 'Anticipación',
              value: prefs.diasAnticipacion == 1
                  ? '1 día antes · 9:00 AM'
                  : '${prefs.diasAnticipacion} días antes · 9:00 AM',
            ),
          ],
          if (prefs.renovaciones && scheduledCount == 0) ...[
            const SizedBox(height: DesignTokens.s12),
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            const SizedBox(height: DesignTokens.s12),
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(width: DesignTokens.s8),
                Text(
                  'Sin renovaciones futuras que notificar',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.4)),
        const SizedBox(width: DesignTokens.s8),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 12,
              fontWeight: DesignTokens.wMedium,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: DesignTokens.s4, bottom: DesignTokens.s4),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 11,
          fontWeight: DesignTokens.wSemibold,
          letterSpacing: 1.2,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ─── Toggle row ───────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.s16, vertical: DesignTokens.s4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignTokens.rS),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: DesignTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 15,
                    fontWeight: DesignTokens.wSemibold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: DesignTokens.success,
            activeTrackColor: DesignTokens.success.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ─── Days selector ────────────────────────────────────────────────────────────

class _DaysSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _DaysSelector({required this.selected, required this.onSelect});

  static const _options = [
    (days: 1, label: '1 día'),
    (days: 3, label: '3 días'),
    (days: 7, label: '7 días'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: DesignTokens.s16,
        right: DesignTokens.s16,
        bottom: DesignTokens.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avisar con anticipación',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: DesignTokens.s8),
          Row(
            children: _options.map((opt) {
              final isSelected = selected == opt.days;
              return Padding(
                padding: const EdgeInsets.only(right: DesignTokens.s8),
                child: GestureDetector(
                  onTap: () => onSelect(opt.days),
                  child: AnimatedContainer(
                    duration: DesignTokens.animFast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.s16,
                        vertical: DesignTokens.s8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _kAccent.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.rFull),
                      border: Border.all(
                        color: isSelected
                            ? _kAccent
                            : Colors.white.withValues(alpha: 0.15),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      opt.label,
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? DesignTokens.wSemibold
                            : DesignTokens.wRegular,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: DesignTokens.s16,
      endIndent: DesignTokens.s16,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}
