import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/providers/notification_prefs_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kAccent = Color(0xFF4F6BFF);

class NotificacionesPage extends ConsumerWidget {
  const NotificacionesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);

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
          _SectionLabel('EN LA APP'),
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
          _PushComingSoonCard(),
        ],
      ),
    );
  }
}

// ─── Section label ─────────────────────────────────────────────────────────────

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
      padding: EdgeInsets.only(
        left: DesignTokens.s16,
        right: DesignTokens.s8,
        top: isLast ? DesignTokens.s4 : DesignTokens.s4,
        bottom: isLast ? DesignTokens.s4 : DesignTokens.s4,
      ),
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

// ─── Push coming soon card ────────────────────────────────────────────────────

class _PushComingSoonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(color: _kAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: _kAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: DesignTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificaciones push',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 14,
                    fontWeight: DesignTokens.wSemibold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Próximamente podrás recibir alertas directamente en tu dispositivo.',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
