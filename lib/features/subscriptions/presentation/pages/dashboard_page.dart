import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/auth/auth_provider.dart';
import 'package:subscan/features/subscriptions/presentation/notifiers/subscription_notifier.dart';
import 'package:subscan/features/subscriptions/presentation/pages/add_subscription_page.dart';
import 'package:subscan/features/subscriptions/presentation/pages/subscription_detail_page.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

/// Pantalla de inicio (Dashboard) con resumen de suscripciones
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);
    final user = ref.watch(currentUserProvider);

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

    final displayName = user?.displayName?.split(' ').first ?? 'Usuario';

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: CustomScrollView(
        slivers: [
          // Header with greeting
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.s24,
                vertical: DesignTokens.s20,
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting row with avatar
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: DesignTokens.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontFamily: DesignTokens.fontFamily,
                                fontSize: 20,
                                fontWeight: DesignTokens.wBold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.s16),
                        // Greeting text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting()}, $displayName',
                                style: const TextStyle(
                                  fontFamily: DesignTokens.fontFamily,
                                  fontSize: 18,
                                  fontWeight: DesignTokens.wSemibold,
                                  color: DesignTokens.textPrimary,
                                ),
                              ),
                              Text(
                                _getDateLabel(),
                                style: TextStyle(
                                  fontFamily: DesignTokens.fontFamily,
                                  fontSize: 12,
                                  color: DesignTokens.textSecondary,
                                  fontWeight: DesignTokens.wRegular,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.s20),
                    // Search bar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: DesignTokens.surface,
                        borderRadius: BorderRadius.circular(DesignTokens.rM),
                        border: Border.all(
                          color: DesignTokens.divider,
                        ),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar un servicio...',
                          hintStyle: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 14,
                            color: DesignTokens.textDisabled,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: DesignTokens.textSecondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: DesignTokens.s12,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 14,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.s24,
                vertical: DesignTokens.s20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRÓXIMOS PAGOS section
                  _ProximosPagosSection(state: state, context: context),
                  const SizedBox(height: DesignTokens.s32),
                  // SUSCRIPCIONES VENCIDAS section (only shown when there are expired subs)
                  if (state.allSubscriptions.any((s) => s.isVencida)) ...[
                    _VencidasSection(state: state, context: context),
                    const SizedBox(height: DesignTokens.s32),
                  ],
                  // SERVICIOS MÁS POPULARES section
                  _ServiciosPopularesSection(state: state),
                  const SizedBox(height: DesignTokens.s32),
                  // AUMENTO DE PRECIOS section
                  _AumentoPreciosSection(state: state),
                  const SizedBox(height: DesignTokens.s24),
                  // Footer message
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.s16),
                    decoration: BoxDecoration(
                      color: DesignTokens.surfaceVariant,
                      borderRadius: BorderRadius.circular(DesignTokens.rM),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: DesignTokens.warning,
                          size: 20,
                        ),
                        const SizedBox(width: DesignTokens.s12),
                        Expanded(
                          child: Text(
                            '¿Necesitas más consejos? Puedes ver reportes aquí',
                            style: TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 12,
                              color: DesignTokens.textSecondary,
                              fontWeight: DesignTokens.wRegular,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.s80),
                ],
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _getDateLabel() {
    final now = DateTime.now();
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    const weekdays = [
      'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
    ];
    return '${weekdays[now.weekday - 1]} ${now.day} de ${months[now.month - 1]}';
  }
}

// ─── Secciones ───────────────────────────────────────────────────────────────

void _openDetail(BuildContext context, sub) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, _) =>
        SubscriptionDetailPage(subscription: sub),
    transitionsBuilder: (_, anim, _, child) =>
        FadeTransition(opacity: anim, child: child),
    transitionDuration: DesignTokens.animNormal,
  ));
}

class _ProximosPagosSection extends StatelessWidget {
  final SubscriptionState state;
  final BuildContext context;
  const _ProximosPagosSection({required this.state, required this.context});

  @override
  Widget build(BuildContext context) {
    // Only non-expired subscriptions, sorted by next renewal date
    final allSorted = [
      ...state.urgentes,
      ...state.proximas,
      ...state.normales.where((s) => !s.isVencida),
    ]..sort((a, b) => a.fechaRenovacion.compareTo(b.fechaRenovacion));

    final items = allSorted.take(2).toList();

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRÓXIMOS PAGOS',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 12,
              fontWeight: DesignTokens.wBold,
              color: DesignTokens.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: DesignTokens.s8),
          Text(
            'No hay pagos próximos',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 13,
              color: DesignTokens.textDisabled,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRÓXIMOS PAGOS',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 12,
            fontWeight: DesignTokens.wBold,
            color: DesignTokens.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: DesignTokens.s12),
        ...items.map((sub) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.s12),
              child: GestureDetector(
                onTap: () => _openDetail(context, sub),
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.s12),
                  decoration: BoxDecoration(
                    color: DesignTokens.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.rM),
                    border: Border.all(color: DesignTokens.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DesignTokens.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            sub.nombre.isNotEmpty
                                ? sub.nombre[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 16,
                              fontWeight: DesignTokens.wBold,
                              color: DesignTokens.primary,
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
                              sub.nombre,
                              style: const TextStyle(
                                fontFamily: DesignTokens.fontFamily,
                                fontSize: 13,
                                fontWeight: DesignTokens.wSemibold,
                                color: DesignTokens.textPrimary,
                              ),
                            ),
                            Text(
                              _diasLabel(sub.diasRestantes),
                              style: TextStyle(
                                fontFamily: DesignTokens.fontFamily,
                                fontSize: 11,
                                color: sub.isUrgent
                                    ? DesignTokens.error
                                    : DesignTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: DesignTokens.textSecondary,
                        size: 18,
                      ),
                      Text(
                        'Q${sub.precioActual.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 14,
                          fontWeight: DesignTokens.wBold,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

String _diasLabel(int dias) {
  if (dias == 0) return 'Vence hoy';
  if (dias == 1) return 'Vence mañana';
  return 'Vence en $dias días';
}

class _VencidasSection extends StatelessWidget {
  final SubscriptionState state;
  final BuildContext context;
  const _VencidasSection({required this.state, required this.context});

  @override
  Widget build(BuildContext context) {
    final vencidas = state.allSubscriptions
        .where((s) => s.isVencida)
        .toList()
      ..sort((a, b) => a.fechaRenovacion.compareTo(b.fechaRenovacion));

    if (vencidas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUSCRIPCIONES VENCIDAS',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 12,
            fontWeight: DesignTokens.wBold,
            color: DesignTokens.error,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: DesignTokens.s12),
        ...vencidas.map((sub) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.s12),
              child: GestureDetector(
                onTap: () => _openDetail(context, sub),
                child: Container(
                padding: const EdgeInsets.all(DesignTokens.s12),
                decoration: BoxDecoration(
                  color: DesignTokens.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DesignTokens.rM),
                  border: Border.all(
                    color: DesignTokens.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DesignTokens.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          sub.nombre.isNotEmpty
                              ? sub.nombre[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 16,
                            fontWeight: DesignTokens.wBold,
                            color: DesignTokens.error,
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
                            sub.nombre,
                            style: const TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 13,
                              fontWeight: DesignTokens.wSemibold,
                              color: DesignTokens.textPrimary,
                            ),
                          ),
                          Text(
                            'Venció hace ${sub.diasRestantes.abs()} día${sub.diasRestantes.abs() == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 11,
                              color: DesignTokens.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Q${sub.precioActual.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 14,
                        fontWeight: DesignTokens.wBold,
                        color: DesignTokens.error,
                      ),
                    ),
                  ],
                ),
              ),
              ),
            )),
      ],
    );
  }
}

class _ServiciosPopularesSection extends StatelessWidget {
  final SubscriptionState state;
  const _ServiciosPopularesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    // Get 3 most common services
    Map<String, int> serviceCount = {};
    for (var sub in state.allSubscriptions) {
      serviceCount[sub.nombre] = (serviceCount[sub.nombre] ?? 0) + 1;
    }

    final topServices = serviceCount.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final items = topServices.take(3).toList();

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SERVICIOS MÁS POPULARES',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 12,
              fontWeight: DesignTokens.wBold,
              color: DesignTokens.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: DesignTokens.s8),
          Text(
            'No hay servicios disponibles',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 13,
              color: DesignTokens.textDisabled,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SERVICIOS MÁS POPULARES',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 12,
            fontWeight: DesignTokens.wBold,
            color: DesignTokens.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: DesignTokens.s12),
        Row(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < items.length - 1 ? DesignTokens.s8 : 0,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: DesignTokens.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          item.key.isNotEmpty
                              ? item.key[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 24,
                            fontWeight: DesignTokens.wBold,
                            color: DesignTokens.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.s8),
                    Text(
                      item.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 12,
                        fontWeight: DesignTokens.wMedium,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    Text(
                      '${item.value} suscripciones',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 10,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AumentoPreciosSection extends StatelessWidget {
  final SubscriptionState state;
  const _AumentoPreciosSection({required this.state});

  @override
  Widget build(BuildContext context) {
    // Get subscriptions with price increases
    final withIncreases = state.allSubscriptions
        .where((sub) =>
            sub.precioOriginal != null &&
            sub.precioOriginal! > sub.precioActual)
        .toList()
        ..sort((a, b) {
          final increaseA = ((a.precioOriginal! - a.precioActual) / a.precioActual * 100);
          final increaseB = ((b.precioOriginal! - b.precioActual) / b.precioActual * 100);
          return increaseB.compareTo(increaseA);
        });

    final items = withIncreases.take(3).toList();

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUMENTO DE PRECIOS',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 12,
              fontWeight: DesignTokens.wBold,
              color: DesignTokens.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: DesignTokens.s8),
          Text(
            'No hay aumentos de precios registrados',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 13,
              color: DesignTokens.textDisabled,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AUMENTO DE PRECIOS',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 12,
            fontWeight: DesignTokens.wBold,
            color: DesignTokens.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: DesignTokens.s12),
        ...items.map((sub) {
          final increase = ((sub.precioOriginal! - sub.precioActual) /
              sub.precioActual *
              100);
          return Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.s12),
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.s12),
              decoration: BoxDecoration(
                color: DesignTokens.surface,
                borderRadius: BorderRadius.circular(DesignTokens.rM),
                border: Border.all(color: DesignTokens.divider),
              ),
              child: Row(
                children: [
                  // Service avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DesignTokens.warning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        sub.nombre.isNotEmpty
                            ? sub.nombre[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 16,
                          fontWeight: DesignTokens.wBold,
                          color: DesignTokens.warning,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.s12),
                  // Service info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.nombre,
                          style: const TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 13,
                            fontWeight: DesignTokens.wSemibold,
                            color: DesignTokens.textPrimary,
                          ),
                        ),
                        Text(
                          'Sube de Q${sub.precioActual.toStringAsFixed(2)} a Q${sub.precioOriginal!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 11,
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Increase percentage
                  Text(
                    '+${increase.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 14,
                      fontWeight: DesignTokens.wBold,
                      color: DesignTokens.warning,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
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
