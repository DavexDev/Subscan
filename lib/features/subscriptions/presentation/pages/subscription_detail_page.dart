import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kGreen = Color(0xFF07D47B);
const Color _kRed = Color(0xFFE5223A);

/// Pantalla de detalle completo de una suscripción — diseño APPS dark theme.
class SubscriptionDetailPage extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionDetailPage({super.key, required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);
    final current = state.allSubscriptions.firstWhere(
      (s) => s.id == subscription.id,
      orElse: () => subscription,
    );

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          _DarkDetailAppBar(subscription: current),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.s16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: DesignTokens.s16),
                _AppHeaderRow(subscription: current),
                const SizedBox(height: DesignTokens.s16),
                _InfoColumnsCard(subscription: current),
                const SizedBox(height: DesignTokens.s16),
                _UsageCard(subscription: current),
                const SizedBox(height: DesignTokens.s16),
                _BenefitsCard(subscription: current),
                const SizedBox(height: DesignTokens.s16),
                _PaymentHistoryCard(subscription: current),
                const SizedBox(height: DesignTokens.s24),
                _RenewButton(
                  onRenew: () {
                    ref
                        .read(subscriptionNotifierProvider.notifier)
                        .renewSubscription(current.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${current.nombre} renovado por 30 días más ✅',
                        ),
                        backgroundColor: DesignTokens.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: DesignTokens.s12),
                _CancelButton(
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: _kCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.rL),
                        ),
                        title: const Text(
                          'Eliminar suscripción',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            color: Colors.white,
                          ),
                        ),
                        content: Text(
                          '¿Deseas eliminar "${current.nombre}"?',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontFamily: DesignTokens.fontFamily,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kRed,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(
                                fontFamily: DesignTokens.fontFamily,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      ref
                          .read(subscriptionNotifierProvider.notifier)
                          .deleteSubscription(current.id);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: DesignTokens.s48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _DarkDetailAppBar extends StatelessWidget {
  final Subscription subscription;
  const _DarkDetailAppBar({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _kBg,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: DesignTokens.s16),
      ],
    );
  }
}

// ─── App Header Row ───────────────────────────────────────────────────────────

class _AppHeaderRow extends StatelessWidget {
  final Subscription subscription;
  const _AppHeaderRow({required this.subscription});

  Color get _iconBg {
    final colors = [
      const Color(0xFF7C3AED),
      const Color(0xFF0582C3),
      const Color(0xFFE5223A),
      const Color(0xFF07D47B),
      const Color(0xFFC39500),
      const Color(0xFF1DB954),
      const Color(0xFFFF5500),
    ];
    if (subscription.nombre.isEmpty) return colors[0];
    return colors[subscription.nombre.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
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
                fontSize: 22,
                fontWeight: DesignTokens.wBold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subscription.nombre,
                style: const TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 18,
                  fontWeight: DesignTokens.wBold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Plan premium individual',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Q${subscription.precioActual.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 18,
                fontWeight: DesignTokens.wBold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Mensual',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DesignTokens.rFull),
                border: Border.all(color: _kGreen.withValues(alpha: 0.5)),
              ),
              child: const Text(
                'ACTIVA',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 10,
                  fontWeight: DesignTokens.wBold,
                  color: _kGreen,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Info Columns Card ────────────────────────────────────────────────────────

class _InfoColumnsCard extends StatelessWidget {
  final Subscription subscription;
  const _InfoColumnsCard({required this.subscription});

  static const List<String> _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  String get _renewalDate {
    final d = subscription.fechaRenovacion;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String get _daysLabel {
    final dias = subscription.diasRestantes;
    if (dias <= 0) return 'Hoy';
    return 'En $dias días';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _InfoColumn(
                icon: Icons.calendar_today_rounded,
                topLabel: 'Próximo pago',
                mainValue: _renewalDate,
                mainColor: _kGreen,
                bottomLabel: _daysLabel,
              ),
            ),
            _VDiv(),
            Expanded(
              child: _InfoColumn(
                icon: Icons.credit_card_rounded,
                topLabel: 'Método de pago',
                mainValue: 'Visa *****4521',
                mainColor: Colors.white,
                bottomLabel: 'Sin método alternativo',
              ),
            ),
            _VDiv(),
            Expanded(
              child: _InfoColumn(
                icon: Icons.autorenew_rounded,
                topLabel: 'Renovación',
                mainValue: 'Automática',
                mainColor: _kGreen,
                bottomLabel: 'Mensual',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String topLabel;
  final String mainValue;
  final Color mainColor;
  final String bottomLabel;

  const _InfoColumn({
    required this.icon,
    required this.topLabel,
    required this.mainValue,
    required this.mainColor,
    required this.bottomLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(
          topLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          mainValue,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 11,
            fontWeight: DesignTokens.wSemibold,
            color: mainColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          bottomLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _VDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.s8),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

// ─── Usage Card ───────────────────────────────────────────────────────────────

class _UsageCard extends StatelessWidget {
  final Subscription subscription;
  const _UsageCard({required this.subscription});

  int get _daysUsed {
    final diff = DateTime.now().difference(subscription.createdAt).inDays;
    return diff.clamp(0, 30);
  }

  @override
  Widget build(BuildContext context) {
    final used = _daysUsed;
    final progress = used / 30.0;

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
            'Uso de tu suscripción',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 15,
              fontWeight: DesignTokens.wSemibold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DesignTokens.s8),
          Text(
            'Has usado ${subscription.nombre} por $used días este ciclo.',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: DesignTokens.s12),
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.rFull),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: DesignTokens.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$used días usados',
                style: const TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 12,
                  fontWeight: DesignTokens.wMedium,
                  color: _kGreen,
                ),
              ),
              Text(
                '30 días totales',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Benefits Card ────────────────────────────────────────────────────────────

class _BenefitsCard extends StatelessWidget {
  final Subscription subscription;
  const _BenefitsCard({required this.subscription});

  static const List<String> _benefits = [
    'Acceso ilimitado a contenido premium',
    'Descarga para uso sin conexión',
    'Calidad de audio/video en alta definición',
    'Soporte prioritario al cliente',
    'Sin anuncios durante la experiencia',
  ];

  @override
  Widget build(BuildContext context) {
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
            'Beneficios de tu plan',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 15,
              fontWeight: DesignTokens.wSemibold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DesignTokens.s12),
          ..._benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.s8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: _kGreen,
                    size: 18,
                  ),
                  const SizedBox(width: DesignTokens.s8),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Payment History Card ─────────────────────────────────────────────────────

class _PaymentHistoryCard extends StatelessWidget {
  final Subscription subscription;
  const _PaymentHistoryCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final base = subscription.precioActual;
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul'];
    final values = [
      base * 0.95,
      base * 1.0,
      base * 0.95,
      base * 1.05,
      base * 1.0,
      base * 0.95,
      base * 1.0,
    ];
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final avg = values.fold<double>(0, (s, v) => s + v) / values.length;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historial de pagos',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 15,
                  fontWeight: DesignTokens.wSemibold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Promedio Q${avg.toStringAsFixed(2)}/mes',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.s16),
          SizedBox(
            height: 100,
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
                        heightFactor: ratio.clamp(0.1, 1.0),
                        child: Container(
                          width: 28,
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
    );
  }
}

// ─── Botones ──────────────────────────────────────────────────────────────────

class _RenewButton extends StatelessWidget {
  final VoidCallback onRenew;
  const _RenewButton({required this.onRenew});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onRenew,
        icon: const Icon(Icons.autorenew_rounded, color: Colors.white),
        label: const Text(
          'Renovar suscripción',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 15,
            fontWeight: DesignTokens.wSemibold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.rL),
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onDelete;
  const _CancelButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onDelete,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC50000),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.rL),
          ),
        ),
        child: const Text(
          'CANCELAR SUSCRIPCIÓN',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 15,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
