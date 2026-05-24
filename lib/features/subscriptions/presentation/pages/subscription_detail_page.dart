import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/presentation/pages/add_subscription_page.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

/// Pantalla de detalle completo de una suscripción.
class SubscriptionDetailPage extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionDetailPage({super.key, required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar el estado actualizado para reflejar cambios (ej. renovación)
    final state = ref.watch(subscriptionNotifierProvider);
    final current = state.allSubscriptions.firstWhere(
      (s) => s.id == subscription.id,
      orElse: () => subscription,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _DetailAppBar(subscription: current),
          SliverPadding(
            padding: const EdgeInsets.all(DesignTokens.s16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _PriceCard(subscription: current),
                const SizedBox(height: DesignTokens.s16),
                _RenewalCard(subscription: current),
                const SizedBox(height: DesignTokens.s16),
                _MetaCard(subscription: current),
                const SizedBox(height: DesignTokens.s32),
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
                _DeleteButton(
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DesignTokens.rL),
                        ),
                        title: const Text('Eliminar suscripción'),
                        content:
                            Text('¿Deseas eliminar "${current.nombre}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignTokens.error,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar'),
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

class _DetailAppBar extends StatelessWidget {
  final Subscription subscription;
  const _DetailAppBar({required this.subscription});

  void _openEdit(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) =>
            AddSubscriptionPage(subscription: subscription),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: DesignTokens.animNormal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
        color: Colors.white,
      ),
      actions: [
        IconButton(
          tooltip: 'Editar',
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          onPressed: () => _openEdit(context),
        ),
        const SizedBox(width: DesignTokens.s4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: subscription.isUrgent
                ? DesignTokens.urgentGradient
                : DesignTokens.headerGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.s24,
                vertical: DesignTokens.s16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(DesignTokens.rM),
                        ),
                        child: Center(
                          child: Text(
                            subscription.nombre.isEmpty
                                ? '?'
                                : subscription.nombre[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: DesignTokens.wBold,
                              fontFamily: DesignTokens.fontFamily,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.nombre,
                              style: const TextStyle(
                                fontFamily: DesignTokens.fontFamily,
                                fontSize: 22,
                                fontWeight: DesignTokens.wBold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Fuente: ${subscription.fuente}',
                              style: TextStyle(
                                fontFamily: DesignTokens.fontFamily,
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: DesignTokens.primary,
    );
  }
}

// ─── Cards de información ─────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.s20),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.s12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 10,
          fontWeight: DesignTokens.wBold,
          color: DesignTokens.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final Subscription subscription;
  const _PriceCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Precio'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${subscription.precioActual.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: DesignTokens.primary,
                    ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: DesignTokens.s8),
                child: Text(
                  ' /mes',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 16,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (subscription.precioOriginal != null &&
              subscription.precioOriginal != subscription.precioActual) ...[
            const SizedBox(height: DesignTokens.s4),
            Row(
              children: [
                const Icon(
                  Icons.arrow_downward_rounded,
                  size: 14,
                  color: DesignTokens.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'Precio original: \$${subscription.precioOriginal!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 12,
                    color: DesignTokens.success,
                    fontWeight: DesignTokens.wMedium,
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

class _RenewalCard extends StatelessWidget {
  final Subscription subscription;
  const _RenewalCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final dias = subscription.diasRestantes;
    final color = subscription.isUrgent
        ? DesignTokens.error
        : subscription.isNearRenewal
            ? DesignTokens.warning
            : DesignTokens.success;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Próxima renovación'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(subscription.fechaRenovacion),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: DesignTokens.s4),
                  Text(
                    dias <= 0
                        ? 'Vence hoy'
                        : 'En $dias ${dias == 1 ? 'día' : 'días'}',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 13,
                      fontWeight: DesignTokens.wSemibold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  subscription.isUrgent
                      ? Icons.warning_amber_rounded
                      : subscription.isNearRenewal
                          ? Icons.access_time_rounded
                          : Icons.check_circle_outline_rounded,
                  color: color,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.s16),
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.rFull),
            child: LinearProgressIndicator(
              value: dias <= 0 ? 1.0 : (1.0 - (dias.clamp(0, 30) / 30.0)),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _MetaCard extends StatelessWidget {
  final Subscription subscription;
  const _MetaCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Información'),
          _MetaRow(
            icon: Icons.fingerprint_rounded,
            label: 'ID',
            value: subscription.id,
          ),
          const Divider(height: DesignTokens.s20),
          _MetaRow(
            icon: Icons.source_rounded,
            label: 'Fuente',
            value: subscription.fuente == 'gmail' ? 'Gmail' : 'Manual',
          ),
          const Divider(height: DesignTokens.s20),
          _MetaRow(
            icon: Icons.calendar_today_rounded,
            label: 'Registrado',
            value: _formatDate(subscription.createdAt),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: DesignTokens.textSecondary),
        const SizedBox(width: DesignTokens.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: DesignTokens.wMedium,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Botones de acción ────────────────────────────────────────────────────────

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
        icon: const Icon(Icons.check_circle_outline_rounded),
        label: const Text('Renovar suscripción'),
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 16,
            fontWeight: DesignTokens.wSemibold,
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;
  const _DeleteButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline_rounded, color: DesignTokens.error),
        label: const Text(
          'Eliminar suscripción',
          style: TextStyle(color: DesignTokens.error),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: DesignTokens.error),
          textStyle: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 16,
            fontWeight: DesignTokens.wSemibold,
          ),
        ),
      ),
    );
  }
}
