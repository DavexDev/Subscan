import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/presentation/notifiers/subscription_notifier.dart';
import 'package:subscan/features/subscriptions/presentation/pages/add_subscription_page.dart';
import 'package:subscan/features/subscriptions/presentation/pages/subscription_detail_page.dart';
import 'package:subscan/features/subscriptions/presentation/widgets/subscription_card.dart';
import 'package:subscan/features/subscriptions/presentation/widgets/urgent_banner.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

/// Pantalla principal que lista todas las suscripciones.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);

    // Mostrar error tipo SnackBar
    ref.listen<SubscriptionState>(subscriptionNotifierProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: DesignTokens.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(subscriptionNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _DashboardAppBar(state: state),
          SliverToBoxAdapter(
            child: UrgentBanner(urgentes: state.urgentes),
          ),
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DesignTokens.primary,
                  ),
                ),
              ),
            )
          else if (state.allSubscriptions.isEmpty)
            const SliverFillRemaining(child: _EmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.only(
                top: DesignTokens.s8,
                bottom: DesignTokens.s80,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sub = state.allSubscriptions[index];
                    return SubscriptionCard(
                      key: ValueKey(sub.id),
                      subscription: sub,
                      onRenew: () => ref
                          .read(subscriptionNotifierProvider.notifier)
                          .renewSubscription(sub.id),
                      onDelete: () => _confirmDelete(context, ref, sub),
                      onTap: () => _openDetail(context, sub),
                    );
                  },
                  childCount: state.allSubscriptions.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _DashboardFABs(
        onAdd: () => _openAdd(context, ref),
        onSyncGmail: () => _syncGmail(context, ref),
      ),
    );
  }

  void _openAdd(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) =>
            const AddSubscriptionPage(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: DesignTokens.animNormal,
      ),
    );
  }

  Future<void> _syncGmail(BuildContext context, WidgetRef ref) async {
    await ref.read(subscriptionNotifierProvider.notifier).syncGmail();
    if (context.mounted) {
      final error = ref.read(subscriptionNotifierProvider).error;
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gmail sincronizado ✅'),
            backgroundColor: DesignTokens.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openDetail(BuildContext context, Subscription sub) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SubscriptionDetailPage(subscription: sub),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: DesignTokens.animNormal,
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Subscription sub) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.rL),
        ),
        title: const Text('Eliminar suscripción'),
        content: Text('¿Deseas eliminar "${sub.nombre}"?'),
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
    if (confirm == true) {
      ref.read(subscriptionNotifierProvider.notifier).deleteSubscription(sub.id);
    }
  }
}

// ─── Sliver App Bar ──────────────────────────────────────────────────────────

class _DashboardAppBar extends ConsumerWidget {
  final SubscriptionState state;
  const _DashboardAppBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = state.allSubscriptions.fold<double>(
      0,
      (sum, s) => sum + s.precioActual,
    );

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      actions: [
        // Sincronizar Gmail
        IconButton(
          tooltip: 'Sincronizar Gmail',
          icon: const Icon(Icons.email_outlined, color: Colors.white),
          onPressed: state.isLoading
              ? null
              : () async {
                  await ref
                      .read(subscriptionNotifierProvider.notifier)
                      .syncGmail();
                  if (context.mounted) {
                    final err =
                        ref.read(subscriptionNotifierProvider).error;
                    if (err == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gmail sincronizado ✅'),
                          backgroundColor: DesignTokens.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
        ),
        // Actualizar / refresh
        IconButton(
          tooltip: 'Actualizar',
          icon: state.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: state.isLoading
              ? null
              : () => ref
                  .read(subscriptionNotifierProvider.notifier)
                  .loadSubscriptions(),
        ),
        const SizedBox(width: DesignTokens.s4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
              gradient: DesignTokens.headerGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.s24,
                vertical: DesignTokens.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'SubScan',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 26,
                      fontWeight: DesignTokens.wExtraBold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.s4),
                  Text(
                    '${state.allSubscriptions.length} suscripciones · \$${total.toStringAsFixed(2)}/mes',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: DesignTokens.wMedium,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.s16),
                  _SummaryChips(state: state),
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

class _SummaryChips extends StatelessWidget {
  final SubscriptionState state;
  const _SummaryChips({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: '${state.urgentes.length} urgentes',
          color: DesignTokens.error,
        ),
        const SizedBox(width: DesignTokens.s8),
        _Chip(
          label: '${state.proximas.length} próximas',
          color: DesignTokens.warning,
        ),
        const SizedBox(width: DesignTokens.s8),
        _Chip(
          label: '${state.normales.length} al día',
          color: DesignTokens.success,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.s10,
        vertical: DesignTokens.s4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(DesignTokens.rFull),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 11,
          fontWeight: DesignTokens.wSemibold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DesignTokens.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 40,
                color: DesignTokens.textDisabled,
              ),
            ),
            const SizedBox(height: DesignTokens.s20),
            Text(
              'Sin suscripciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: DesignTokens.s8),
            Text(
              'Toca el botón de recarga para sincronizar\ncon Gmail o agrega una manualmente.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FABs ─────────────────────────────────────────────────────────────────────

class _DashboardFABs extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onSyncGmail;

  const _DashboardFABs({
    required this.onAdd,
    required this.onSyncGmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // FAB secundario — Gmail sync
        FloatingActionButton.small(
          heroTag: 'fab_gmail',
          onPressed: onSyncGmail,
          backgroundColor: DesignTokens.surface,
          foregroundColor: DesignTokens.primary,
          tooltip: 'Sincronizar Gmail',
          elevation: DesignTokens.e2,
          child: const Icon(Icons.email_outlined),
        ),
        const SizedBox(height: DesignTokens.s12),
        // FAB principal — Añadir suscripción
        FloatingActionButton.extended(
          heroTag: 'fab_add',
          onPressed: onAdd,
          backgroundColor: DesignTokens.primary,
          foregroundColor: Colors.white,
          elevation: DesignTokens.e4,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Añadir',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontWeight: DesignTokens.wSemibold,
            ),
          ),
        ),
      ],
    );
  }
}
