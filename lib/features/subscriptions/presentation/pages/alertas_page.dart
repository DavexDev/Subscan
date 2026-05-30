import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/presentation/notifiers/subscription_notifier.dart';
import 'package:subscan/features/subscriptions/providers/notification_prefs_provider.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';
import 'package:subscan/core/widgets/service_logo.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kCardDark = Color(0xFF0F1F70);

// Badge colors
const Color _kBadgeRed = Color(0xFFC30000);
const Color _kBadgeOrange = Color(0xFFC39500);

// Paleta de colores para iconos (determinista por nombre)
const List<Color> _kIconPalette = [
  Color(0xFFE5223A),
  Color(0xFF1DB954),
  Color(0xFF0F3FA2),
  Color(0xFFFF5500),
  Color(0xFF5822CC),
  Color(0xFF00C4CC),
  Color(0xFFFF0000),
];

const List<String> _kMonths = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

Color _iconColorFor(String name) =>
    _kIconPalette[name.isEmpty ? 0 : name.codeUnitAt(0) % _kIconPalette.length];

String _fmtDate(DateTime d) => '${d.day} de ${_kMonths[d.month - 1]}';

// ─── Modelos internos de alerta ───────────────────────────────────────────────

class _AlertItem {
  final String app;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final String time;
  final Color iconColor;

  const _AlertItem({
    required this.app,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.time,
    required this.iconColor,
  });
}

class _AlertGroup {
  final String dateHeader;
  final List<_AlertItem> items;

  const _AlertGroup({required this.dateHeader, required this.items});
}

// ─── Derivación de alertas desde el estado real ───────────────────────────────

_AlertItem _toPaymentAlert(Subscription s) {
  final dias = s.diasRestantes;
  final isUrgent = dias <= 1;
  final title = dias <= 0
      ? '${s.nombre} vence hoy'
      : dias == 1
          ? '${s.nombre} vence mañana'
          : '${s.nombre} vence en $dias días';
  return _AlertItem(
    app: s.nombre,
    title: title,
    subtitle:
        'Tu pago de Q${s.precioActual.toStringAsFixed(2)} se procesará el ${_fmtDate(s.fechaRenovacion)}',
    badge: isUrgent ? 'Urgente' : 'Próximo pago',
    badgeColor: isUrgent ? _kBadgeRed : _kBadgeOrange,
    time: _fmtDate(s.fechaRenovacion),
    iconColor: _iconColorFor(s.nombre),
  );
}

_AlertItem _toPriceAlert(Subscription s) {
  return _AlertItem(
    app: s.nombre,
    title: '${s.nombre} aumentará de precio',
    subtitle:
        'La tarifa regular es Q${s.precioOriginal!.toStringAsFixed(2)}/mes. '
        'Actualmente pagas Q${s.precioActual.toStringAsFixed(2)}/mes.',
    badge: 'Importante',
    badgeColor: _kBadgeRed,
    time: _fmtDate(s.fechaRenovacion),
    iconColor: _iconColorFor(s.nombre),
  );
}

List<_AlertGroup> _buildGroups(SubscriptionState state, NotificationPrefs prefs) {
  final groups = <_AlertGroup>[];

  if (prefs.renovaciones) {
    final pagos = state.allSubscriptions
        .where((s) => s.diasRestantes >= 0 && s.diasRestantes <= prefs.diasAnticipacion)
        .map(_toPaymentAlert)
        .toList();
    if (pagos.isNotEmpty) {
      groups.add(_AlertGroup(dateHeader: 'Próximos pagos', items: pagos));
    }
  }

  if (prefs.alertasPrecio) {
    final aumentos = state.allSubscriptions
        .where((s) => s.precioOriginal != null && s.precioOriginal! > s.precioActual)
        .map(_toPriceAlert)
        .toList();
    if (aumentos.isNotEmpty) {
      groups.add(_AlertGroup(dateHeader: 'Aumentos de precio', items: aumentos));
    }
  }

  return groups;
}

// ─── Pantalla de alertas ──────────────────────────────────────────────────────

class AlertasPage extends ConsumerStatefulWidget {
  const AlertasPage({super.key});

  @override
  ConsumerState<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends ConsumerState<AlertasPage> {
  int _selectedFilter = 0;

  List<_AlertGroup> _applyFilter(List<_AlertGroup> groups) {
    if (_selectedFilter == 0) return groups;
    if (_selectedFilter == 1) {
      // Importantes: Urgente + Importante
      return groups.map((g) {
        final filtered = g.items
            .where((i) => i.badge == 'Importante' || i.badge == 'Urgente')
            .toList();
        return _AlertGroup(dateHeader: g.dateHeader, items: filtered);
      }).where((g) => g.items.isNotEmpty).toList();
    }
    // Pagos: Próximo pago + Urgente
    return groups.map((g) {
      final filtered = g.items
          .where((i) => i.badge == 'Próximo pago' || i.badge == 'Urgente')
          .toList();
      return _AlertGroup(dateHeader: g.dateHeader, items: filtered);
    }).where((g) => g.items.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionNotifierProvider);
    final prefs = ref.watch(notificationPrefsProvider);
    final allGroups = _buildGroups(state, prefs);
    final filteredGroups = _applyFilter(allGroups);

    final totalAlertas =
        allGroups.fold<int>(0, (sum, g) => sum + g.items.length);
    final requierenAtencion = allGroups.fold<int>(
      0,
      (sum, g) => sum +
          g.items
              .where((i) => i.badge == 'Importante' || i.badge == 'Urgente')
              .length,
    );

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Alertas',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 22,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(
              left: DesignTokens.s16,
              bottom: DesignTokens.s8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mantente al día con cosas importantes :)',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: DesignTokens.primary),
            )
          : ListView(
              padding: const EdgeInsets.only(
                left: DesignTokens.s16,
                right: DesignTokens.s16,
                top: DesignTokens.s8,
                bottom: DesignTokens.s80,
              ),
              children: [
                _SummaryCard(
                  total: totalAlertas,
                  requierenAtencion: requierenAtencion,
                ),
                const SizedBox(height: DesignTokens.s16),
                _FilterRow(
                  selected: _selectedFilter,
                  onSelect: (i) => setState(() => _selectedFilter = i),
                ),
                const SizedBox(height: DesignTokens.s16),
                if (filteredGroups.isEmpty)
                  const _EmptyAlerts()
                else
                  ...filteredGroups.map(
                    (group) => _AlertGroupSection(group: group),
                  ),
              ],
            ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int total;
  final int requierenAtencion;

  const _SummaryCard({required this.total, required this.requierenAtencion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: DesignTokens.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de alertas',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 14,
                    fontWeight: DesignTokens.wSemibold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'Sin alertas activas'
                      : '$total ${total == 1 ? 'alerta activa' : 'alertas activas'}',
                  style: const TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                if (requierenAtencion > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$requierenAtencion ${requierenAtencion == 1 ? 'requiere' : 'requieren'} atención',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 12,
                      color: Colors.red.shade300,
                      fontWeight: DesignTokens.wMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.s80),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: DesignTokens.s16),
          Text(
            'No tienes alertas por ahora',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  static const List<String> _labels = ['Todas', 'Importantes', 'Pagos'];

  const _FilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (i) {
        final isSelected = i == selected;
        return Padding(
          padding: EdgeInsets.only(
            right: i < _labels.length - 1 ? DesignTokens.s8 : 0,
          ),
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: DesignTokens.animFast,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.s16,
                vertical: DesignTokens.s8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.rFull),
                border: isSelected
                    ? null
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i == 0) ...[
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0082C3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  Text(
                    _labels[i],
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 13,
                      fontWeight: DesignTokens.wMedium,
                      color:
                          isSelected ? const Color(0xFF030B3F) : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Alert Group Section ──────────────────────────────────────────────────────

class _AlertGroupSection extends StatelessWidget {
  final _AlertGroup group;
  const _AlertGroupSection({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.s12),
          child: Text(
            group.dateHeader,
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 12,
              fontWeight: DesignTokens.wSemibold,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _kCardDark,
            borderRadius: BorderRadius.circular(DesignTokens.rL),
          ),
          child: Column(
            children: List.generate(group.items.length, (i) {
              final item = group.items[i];
              final isLast = i == group.items.length - 1;
              return _AlertRow(item: item, isLast: isLast);
            }),
          ),
        ),
        const SizedBox(height: DesignTokens.s8),
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  final _AlertItem item;
  final bool isLast;

  const _AlertRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(DesignTokens.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de app
              ServiceLogo(name: item.app, size: 40),
              const SizedBox(width: DesignTokens.s12),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 13,
                              fontWeight: DesignTokens.wSemibold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.s8),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _BadgePill(label: item.badge, color: item.badgeColor),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.08),
            indent: DesignTokens.s16,
            endIndent: DesignTokens.s16,
          ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.s8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DesignTokens.rFull),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 10,
          fontWeight: DesignTokens.wSemibold,
          color: Colors.white,
        ),
      ),
    );
  }
}
