import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/presentation/notifiers/subscription_notifier.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kGreen = Color(0xFF07D47B);
const Color _kRed = Color(0xFFE5223A);
const Color _kYellow = Color(0xFFEDC21E);
const Color _kCyan = Color(0xFF1ECCD2);

/// Pantalla de estadísticas de suscripciones.
class EstadisticasPage extends ConsumerWidget {
  const EstadisticasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Estadísticas',
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
                'Resumen de tus suscripciones',
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
                _SummaryCard(state: state),
                const SizedBox(height: DesignTokens.s20),
                _CalendarWidget(),
                const SizedBox(height: DesignTokens.s20),
                _ProximosVencimientos(state: state),
                const SizedBox(height: DesignTokens.s20),
                _BarChart(state: state),
              ],
            ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final SubscriptionState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final gastoMes = state.allSubscriptions.fold<double>(
      0,
      (sum, s) => sum + s.precioActual,
    );
    final ahorroPotencial = state.allSubscriptions.fold<double>(
      0,
      (sum, s) =>
          sum +
          ((s.precioOriginal != null && s.precioOriginal! > s.precioActual)
              ? s.precioOriginal! - s.precioActual
              : 0),
    );
    final appsActivas = state.allSubscriptions.length;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.s20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SummaryColumn(
                label: 'Gasto este mes',
                value: 'Q${gastoMes.toStringAsFixed(2)}',
                valueColor: Colors.white,
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: _SummaryColumn(
                label: 'Ahorro potencial',
                value: 'Q${ahorroPotencial.toStringAsFixed(2)}',
                valueColor: _kGreen,
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: _SummaryColumn(
                label: 'Apps activas',
                value: '$appsActivas',
                valueColor: _kCyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: DesignTokens.wMedium,
          ),
        ),
        const SizedBox(height: DesignTokens.s4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 18,
            fontWeight: DesignTokens.wBold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.s8),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

// ─── Calendar ─────────────────────────────────────────────────────────────────

class _CalendarWidget extends StatefulWidget {
  @override
  State<_CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<_CalendarWidget> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1);
    });
  }

  static const List<String> _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  static const List<String> _dayNames = [
    'L', 'M', 'X', 'J', 'V', 'S', 'D',
  ];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // weekday: 1=Mon ... 7=Sun
    final startWeekday = firstDay.weekday; // 1-7

    final today = DateTime.now();
    final isCurrentMonth =
        _month.year == today.year && _month.month == today.month;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: const Color(0xFF08142F),
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                ),
              ),
              Text(
                '${_monthNames[_month.month - 1]} ${_month.year}',
                style: const TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 16,
                  fontWeight: DesignTokens.wSemibold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.s8),
          // Day labels
          Row(
            children: _dayNames
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 12,
                        fontWeight: DesignTokens.wSemibold,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: DesignTokens.s8),
          // Grid
          _buildGrid(
            daysInMonth,
            startWeekday,
            isCurrentMonth ? today.day : -1,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(int daysInMonth, int startWeekday, int todayDay) {
    // startWeekday: 1=Mon => offset = 0; 7=Sun => offset = 6
    final offset = startWeekday - 1;
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final day = cellIndex - offset + 1;
            final isValid = day >= 1 && day <= daysInMonth;
            final isToday = isValid && day == todayDay;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                height: 36,
                decoration: isToday
                    ? BoxDecoration(
                        color: DesignTokens.primary,
                        borderRadius: BorderRadius.circular(DesignTokens.rS),
                      )
                    : null,
                child: Center(
                  child: isValid
                      ? Text(
                          '$day',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 13,
                            fontWeight: isToday
                                ? DesignTokens.wBold
                                : DesignTokens.wRegular,
                            color: isToday
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.85),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ─── Próximos Vencimientos ────────────────────────────────────────────────────

class _ProximosVencimientos extends StatelessWidget {
  final SubscriptionState state;
  const _ProximosVencimientos({required this.state});

  @override
  Widget build(BuildContext context) {
    final items = [
      ...state.urgentes,
      ...state.proximas,
    ]..sort((a, b) => a.fechaRenovacion.compareTo(b.fechaRenovacion));

    final displayItems = items.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximos vencimientos',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 16,
            fontWeight: DesignTokens.wSemibold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: DesignTokens.s12),
        if (displayItems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.s32),
            child: Center(
              child: Text(
                'Sin vencimientos próximos',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(DesignTokens.rL),
            ),
            child: Column(
              children: List.generate(displayItems.length, (i) {
                final sub = displayItems[i];
                final isLast = i == displayItems.length - 1;
                return _VencimientoRow(subscription: sub, isLast: isLast);
              }),
            ),
          ),
      ],
    );
  }
}

class _VencimientoRow extends StatelessWidget {
  final Subscription subscription;
  final bool isLast;

  const _VencimientoRow({required this.subscription, required this.isLast});

  static const List<String> _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  String get _dateLabel {
    final d = subscription.fechaRenovacion;
    return '${d.day} ${_months[d.month - 1]}';
  }

  String get _urgencyText {
    final dias = subscription.diasRestantes;
    if (dias <= 0) return 'Vence hoy';
    if (dias == 1) return 'Renovación mañana';
    if (dias <= 3) return 'Renovación en $dias días';
    return 'Renovación en $dias días';
  }

  Color get _urgencyColor {
    final dias = subscription.diasRestantes;
    if (dias <= 1) return _kRed;
    if (dias <= 3) return _kYellow;
    return _kGreen;
  }

  Color get _iconBg {
    final colors = [
      const Color(0xFF7C3AED),
      const Color(0xFF0582C3),
      const Color(0xFFE5223A),
      const Color(0xFF07D47B),
      const Color(0xFFC39500),
    ];
    return colors[subscription.nombre.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(DesignTokens.s16),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    subscription.nombre.isEmpty
                        ? '?'
                        : subscription.nombre[0].toUpperCase(),
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
              // Name + urgency
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.nombre,
                      style: const TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 14,
                        fontWeight: DesignTokens.wSemibold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _urgencyText,
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 12,
                        color: _urgencyColor,
                        fontWeight: DesignTokens.wMedium,
                      ),
                    ),
                  ],
                ),
              ),
              // Price + date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Q${subscription.precioActual.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 14,
                      fontWeight: DesignTokens.wBold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateLabel,
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.1),
            indent: DesignTokens.s16,
            endIndent: DesignTokens.s16,
          ),
      ],
    );
  }
}

// ─── Bar Chart ────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final SubscriptionState state;
  const _BarChart({required this.state});

  @override
  Widget build(BuildContext context) {
    final base = state.allSubscriptions.isEmpty
        ? 100.0
        : state.allSubscriptions.fold<double>(
            0, (s, sub) => s + sub.precioActual);

    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul'];
    final values = [
      base * 0.72,
      base * 0.85,
      base * 0.91,
      base * 0.78,
      base * 1.0,
      base * 0.88,
      base * 0.95,
    ];
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gasto mensual',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 15,
              fontWeight: DesignTokens.wSemibold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DesignTokens.s16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _yLabel('Q${maxVal.toStringAsFixed(0)}'),
                    _yLabel('Q${(maxVal * 0.75).toStringAsFixed(0)}'),
                    _yLabel('Q${(maxVal * 0.5).toStringAsFixed(0)}'),
                    _yLabel('Q${(maxVal * 0.25).toStringAsFixed(0)}'),
                    _yLabel('Q0'),
                  ],
                ),
                const SizedBox(width: DesignTokens.s8),
                // Bars
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (i) {
                      final ratio = maxVal == 0 ? 0.0 : values[i] / maxVal;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: ratio.clamp(0.05, 1.0),
                              child: Container(
                                width: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF282743),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(DesignTokens.rXS),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            months[i],
                            style: TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _yLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: 9,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}
