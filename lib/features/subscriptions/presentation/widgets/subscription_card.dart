import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';

/// Card que representa una suscripción en la lista del dashboard.
class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onRenew;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onRenew,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.animNormal,
        margin: const EdgeInsets.symmetric(
          horizontal: DesignTokens.s16,
          vertical: DesignTokens.s6,
        ),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(DesignTokens.rL),
          boxShadow: [
            BoxShadow(
              color: _shadowColor.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _borderColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(subscription: subscription),
              const SizedBox(height: DesignTokens.s12),
              _RenewalBar(subscription: subscription),
              const SizedBox(height: DesignTokens.s12),
              _Actions(onRenew: onRenew, onDelete: onDelete),
            ],
          ),
        ),
      ),
    );
  }

  Color get _shadowColor {
    if (subscription.isUrgent) return DesignTokens.error;
    if (subscription.isNearRenewal) return DesignTokens.warning;
    return DesignTokens.primary;
  }

  Color get _borderColor {
    if (subscription.isUrgent) return DesignTokens.error;
    if (subscription.isNearRenewal) return DesignTokens.warning;
    return DesignTokens.divider;
  }
}

class _Header extends StatelessWidget {
  final Subscription subscription;
  const _Header({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Ícono de servicio
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: subscription.isUrgent
                ? DesignTokens.urgentGradient
                : DesignTokens.headerGradient,
            borderRadius: BorderRadius.circular(DesignTokens.rM),
          ),
          child: Center(
            child: Text(
              subscription.nombre.isEmpty
                  ? '?'
                  : subscription.nombre[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: DesignTokens.wBold,
                fontFamily: DesignTokens.fontFamily,
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
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: DesignTokens.s4),
              Row(
                children: [
                  Text(
                    '\$${subscription.precioActual.toStringAsFixed(2)}/mes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                  ),
                  if (subscription.precioOriginal != null &&
                      subscription.precioOriginal != subscription.precioActual)
                    Padding(
                      padding: const EdgeInsets.only(left: DesignTokens.s8),
                      child: Text(
                        '\$${subscription.precioOriginal!.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: DesignTokens.textDisabled,
                            ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        _StatusChip(subscription: subscription),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Subscription subscription;
  const _StatusChip({required this.subscription});

  @override
  Widget build(BuildContext context) {
    if (subscription.isUrgent) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.s8,
          vertical: DesignTokens.s4,
        ),
        decoration: BoxDecoration(
          gradient: DesignTokens.urgentGradient,
          borderRadius: BorderRadius.circular(DesignTokens.rFull),
        ),
        child: const Text(
          'URGENTE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: DesignTokens.wBold,
            fontFamily: DesignTokens.fontFamily,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
    if (subscription.isNearRenewal) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.s8,
          vertical: DesignTokens.s4,
        ),
        decoration: BoxDecoration(
          color: DesignTokens.warningLight,
          borderRadius: BorderRadius.circular(DesignTokens.rFull),
        ),
        child: const Text(
          'PRÓXIMO',
          style: TextStyle(
            color: DesignTokens.warning,
            fontSize: 10,
            fontWeight: DesignTokens.wBold,
            fontFamily: DesignTokens.fontFamily,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _RenewalBar extends StatelessWidget {
  final Subscription subscription;
  const _RenewalBar({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final dias = subscription.diasRestantes;
    final color = subscription.isUrgent
        ? DesignTokens.error
        : subscription.isNearRenewal
            ? DesignTokens.warning
            : DesignTokens.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dias <= 0
                  ? 'Vence hoy'
                  : 'Renueva en $dias ${dias == 1 ? 'día' : 'días'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: DesignTokens.wSemibold,
                  ),
            ),
            Icon(
              subscription.fuente == 'gmail'
                  ? Icons.email_outlined
                  : Icons.edit_outlined,
              size: 14,
              color: DesignTokens.textDisabled,
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.s6),
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.rFull),
          child: LinearProgressIndicator(
            value: _progressValue(dias),
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  double _progressValue(int dias) {
    if (dias <= 0) return 1.0;
    if (dias >= 30) return 0.0;
    return 1.0 - (dias / 30.0);
  }
}

class _Actions extends StatelessWidget {
  final VoidCallback onRenew;
  final VoidCallback onDelete;
  const _Actions({required this.onRenew, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: onRenew,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Renovar'),
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: DesignTokens.wSemibold,
                  fontFamily: DesignTokens.fontFamily,
                ),
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.s12),
              ),
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.s8),
        SizedBox(
          height: 36,
          width: 36,
          child: IconButton.outlined(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            style: IconButton.styleFrom(
              foregroundColor: DesignTokens.error,
              side: const BorderSide(color: DesignTokens.error, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.rS),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


