import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kCardDark = Color(0xFF0F1F70);

// Badge colors
const Color _kBadgeRed = Color(0xFFC30000);
const Color _kBadgeOrange = Color(0xFFC39500);
const Color _kBadgeBlue = Color(0xFF0082C3);
const Color _kBadgeGreen = Color(0xFF35E026);
const Color _kBadgeBlueAlt = Color(0xFF0564AA);

/// Modelo interno de alerta
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

/// Grupo de alertas por fecha
class _AlertGroup {
  final String dateHeader;
  final List<_AlertItem> items;

  const _AlertGroup({required this.dateHeader, required this.items});
}

final List<_AlertGroup> _mockGroups = [
  _AlertGroup(
    dateHeader: 'Hoy • Mar 9 de Mayo',
    items: [
      _AlertItem(
        app: 'Netflix',
        title: 'Netflix Aumentará de precio',
        subtitle: 'A partir del 20 de mayo pagarás Q109.00/mes',
        badge: 'Importante',
        badgeColor: _kBadgeRed,
        time: '9:41 AM',
        iconColor: Color(0xFFE5223A),
      ),
      _AlertItem(
        app: 'Spotify',
        title: 'Spotify vence en 3 días',
        subtitle: 'Tu pago de Q37.57 se procesará el 13 de Mayo',
        badge: 'Próximo pago',
        badgeColor: _kBadgeOrange,
        time: '10:54 AM',
        iconColor: Color(0xFF1DB954),
      ),
      _AlertItem(
        app: 'Disney+',
        title: 'No has usado Disney+ este mes',
        subtitle: 'PODA detectó que no la has usado recientemente',
        badge: 'Recomendación',
        badgeColor: _kBadgeBlue,
        time: '11:24 AM',
        iconColor: Color(0xFF0F3FA2),
      ),
    ],
  ),
  _AlertGroup(
    dateHeader: 'Ayer • Mar 6 de Mayo',
    items: [
      _AlertItem(
        app: 'Soundcloud',
        title: 'Pago Exitoso',
        subtitle: 'Se realizó el pago de Q25.00 correctamente',
        badge: 'Completado',
        badgeColor: _kBadgeGreen,
        time: '9:34 PM',
        iconColor: Color(0xFFFF5500),
      ),
      _AlertItem(
        app: 'HBO MAX',
        title: 'Nuevo plan disponible',
        subtitle: 'HBO MAX tiene un plan más económico',
        badge: 'Información',
        badgeColor: _kBadgeBlueAlt,
        time: '9:34 PM',
        iconColor: Color(0xFF5822CC),
      ),
    ],
  ),
  _AlertGroup(
    dateHeader: 'Esta semana • Mié 2 de Mayo',
    items: [
      _AlertItem(
        app: 'Adobe',
        title: 'Adobe Acrobat Vence en 5 días',
        subtitle: 'Tu pago de Q67.99 se procesará el 7 de Mayo',
        badge: 'Próximo pago',
        badgeColor: _kBadgeOrange,
        time: '9:34 PM',
        iconColor: Color(0xFFFF0000),
      ),
      _AlertItem(
        app: 'Canva',
        title: 'Tu cuenta de Canva Pro vence pronto',
        subtitle: 'Tu pago de Q200.87 se procesará el 15 de Mayo',
        badge: 'Próximo pago',
        badgeColor: _kBadgeOrange,
        time: '9:34 PM',
        iconColor: Color(0xFF00C4CC),
      ),
    ],
  ),
];

/// Pantalla de alertas.
class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  int _selectedFilter = 0;

  List<_AlertGroup> get _filteredGroups {
    if (_selectedFilter == 0) return _mockGroups;
    if (_selectedFilter == 1) {
      return _mockGroups.map((g) {
        final filtered = g.items
            .where((i) => i.badge == 'Importante')
            .toList();
        return _AlertGroup(dateHeader: g.dateHeader, items: filtered);
      }).where((g) => g.items.isNotEmpty).toList();
    }
    // Pagos
    return _mockGroups.map((g) {
      final filtered = g.items
          .where((i) => i.badge == 'Próximo pago' || i.badge == 'Completado')
          .toList();
      return _AlertGroup(dateHeader: g.dateHeader, items: filtered);
    }).where((g) => g.items.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.only(
          left: DesignTokens.s16,
          right: DesignTokens.s16,
          top: DesignTokens.s8,
          bottom: DesignTokens.s80,
        ),
        children: [
          _SummaryCard(),
          const SizedBox(height: DesignTokens.s16),
          _FilterRow(
            selected: _selectedFilter,
            onSelect: (i) => setState(() => _selectedFilter = i),
          ),
          const SizedBox(height: DesignTokens.s16),
          ..._filteredGroups.map((group) => _AlertGroupSection(group: group)),
        ],
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
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
                const Text(
                  '5 nuevas alertas',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '3 Requieren atención',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 12,
                    color: Colors.red.shade300,
                    fontWeight: DesignTokens.wMedium,
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
          padding: EdgeInsets.only(right: i < _labels.length - 1 ? DesignTokens.s8 : 0),
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
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0082C3)
                            : const Color(0xFF0082C3),
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
                      color: isSelected ? const Color(0xFF030B3F) : Colors.white,
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
              // App icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.iconColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.app.isEmpty ? '?' : item.app[0].toUpperCase(),
                    style: const TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      color: Colors.white,
                      fontWeight: DesignTokens.wBold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.s12),
              // Content
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
