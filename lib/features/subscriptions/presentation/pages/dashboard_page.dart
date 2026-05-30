import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/core/widgets/service_logo.dart';
import 'package:subscan/features/auth/auth_provider.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';
import 'package:subscan/features/subscriptions/presentation/notifiers/subscription_notifier.dart';
import 'package:subscan/features/subscriptions/presentation/pages/add_subscription_page.dart';
import 'package:subscan/features/subscriptions/presentation/pages/gmail_sync_overlay_page.dart';
import 'package:subscan/features/subscriptions/presentation/pages/subscription_detail_page.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF0D1854);
const Color _kCardLight = Color(0xFF1A2468);


// ─── Dashboard ────────────────────────────────────────────────────────────────

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);
    final user = ref.watch(currentUserProvider);

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
    final photoUrl = user?.photoURL;

    final gastoPorMoneda = <String, double>{};
    for (final s in state.allSubscriptions.where((s) => !s.isVencida)) {
      gastoPorMoneda[s.currency] = (gastoPorMoneda[s.currency] ?? 0) + s.precioActual;
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    DesignTokens.s20, DesignTokens.s16, DesignTokens.s20, 0),
                child: _Header(
                  displayName: displayName,
                  photoUrl: photoUrl,
                  greeting: _greeting(),
                ),
              ),
            ),
          ),
          // ── Spending summary card ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DesignTokens.s20,
                  DesignTokens.s16, DesignTokens.s20, 0),
              child: _SummaryCard(
                gastoPorMoneda: gastoPorMoneda,
                totalSubs: state.allSubscriptions.where((s) => !s.isVencida).length,
                vencidas: state.allSubscriptions.where((s) => s.isVencida).length,
              ),
            ),
          ),
          // ── Search bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DesignTokens.s20,
                  DesignTokens.s12, DesignTokens.s20, 0),
              child: _SearchBar(),
            ),
          ),
          // ── Content ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                DesignTokens.s20, DesignTokens.s24, DesignTokens.s20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Próximos pagos
                _SectionHeader(
                  title: 'PRÓXIMOS PAGOS',
                  trailing: IconButton(
                    onPressed: () => _openAdd(context, ref),
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: DesignTokens.s12),
                _ProximosPagosRow(state: state, context: context),
                const SizedBox(height: DesignTokens.s24),
                // Vencidas
                if (state.allSubscriptions.any((s) => s.isVencida)) ...[
                  _VencidasSection(state: state, context: context),
                  const SizedBox(height: DesignTokens.s24),
                ],
                // Servicios populares
                const _SectionHeader(title: 'SERVICIOS MÁS POPULARES'),
                const SizedBox(height: DesignTokens.s12),
                _ServiciosPopularesRow(state: state, context: context),
                const SizedBox(height: DesignTokens.s24),
                // Aumento de precios
                if (state.allSubscriptions.any(
                    (s) => s.precioOriginal != null && s.precioOriginal! > s.precioActual)) ...[
                  const _SectionHeader(title: 'AUMENTO DE PRECIOS'),
                  const SizedBox(height: DesignTokens.s12),
                  _AumentoPreciosRow(state: state, context: context),
                ],
              ]),
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
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, _) => const AddSubscriptionPage(),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: DesignTokens.animNormal,
    ));
  }

  Future<void> _syncGmail(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const GmailSyncOverlayPage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: DesignTokens.animNormal,
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String displayName;
  final String? photoUrl;
  final String greeting;

  const _Header({
    required this.displayName,
    required this.photoUrl,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
        const SizedBox(width: DesignTokens.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $displayName',
                style: const TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 20,
                  fontWeight: DesignTokens.wBold,
                  color: Colors.white,
                ),
              ),
              Text(
                _dateLabel(),
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DesignTokens.s8),
        _Avatar(photoUrl: photoUrl, name: displayName),
      ],
    );
  }

  static String _dateLabel() {
    final now = DateTime.now();
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    const weekdays = [
      'lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  const _Avatar({required this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(photoUrl!),
        backgroundColor: DesignTokens.primary,
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: DesignTokens.primary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 18,
          fontWeight: DesignTokens.wBold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────

String _currencySymbol(String code) {
  switch (code) {
    case 'USD': return '\$';
    case 'EUR': return '€';
    case 'MXN': return 'MX\$';
    case 'GBP': return '£';
    default: return 'Q';
  }
}

class _SummaryCard extends StatelessWidget {
  final Map<String, double> gastoPorMoneda;
  final int totalSubs;
  final int vencidas;

  const _SummaryCard({
    required this.gastoPorMoneda,
    required this.totalSubs,
    required this.vencidas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2468), Color(0xFF0D1854)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gasto mensual estimado',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: DesignTokens.s6),
          if (gastoPorMoneda.isEmpty)
            const Text(
              'Q0.00',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 36,
                fontWeight: DesignTokens.wBold,
                color: Colors.white,
                height: 1.1,
              ),
            )
          else if (gastoPorMoneda.length == 1)
            Text(
              '${_currencySymbol(gastoPorMoneda.keys.first)}${gastoPorMoneda.values.first.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 36,
                fontWeight: DesignTokens.wBold,
                color: Colors.white,
                height: 1.1,
              ),
            )
          else
            Wrap(
              spacing: DesignTokens.s16,
              runSpacing: DesignTokens.s4,
              children: gastoPorMoneda.entries.map((e) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_currencySymbol(e.key)}${e.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 26,
                      fontWeight: DesignTokens.wBold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    e.key,
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              )).toList(),
            ),
          const SizedBox(height: DesignTokens.s16),
          Row(
            children: [
              _StatPill(
                icon: Icons.subscriptions_outlined,
                label: '$totalSubs activas',
                color: const Color(0xFF07D47B),
              ),
              const SizedBox(width: DesignTokens.s8),
              if (vencidas > 0)
                _StatPill(
                  icon: Icons.warning_amber_rounded,
                  label: '$vencidas vencida${vencidas == 1 ? '' : 's'}',
                  color: DesignTokens.error,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 11,
              fontWeight: DesignTokens.wSemibold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar un servicio...',
          hintStyle: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.4),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 12,
            fontWeight: DesignTokens.wBold,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 0.8,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─── Próximos pagos horizontal ────────────────────────────────────────────────

void _openDetail(BuildContext context, Subscription sub) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, _) =>
        SubscriptionDetailPage(subscription: sub),
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
    transitionDuration: DesignTokens.animNormal,
  ));
}

class _ProximosPagosRow extends StatelessWidget {
  final SubscriptionState state;
  final BuildContext context;
  const _ProximosPagosRow({required this.state, required this.context});

  @override
  Widget build(BuildContext context) {
    final items = [
      ...state.urgentes,
      ...state.proximas,
      ...state.normales.where((s) => !s.isVencida),
    ]..sort((a, b) => a.fechaRenovacion.compareTo(b.fechaRenovacion));

    if (items.isEmpty) {
      return Text(
        'No hay pagos próximos',
        style: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 13,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      );
    }

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.s10),
        itemBuilder: (_, i) => _ProximoCard(sub: items[i]),
      ),
    );
  }
}

class _ProximoCard extends StatelessWidget {
  final Subscription sub;
  const _ProximoCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    final color = sub.isUrgent ? DesignTokens.error : const Color(0xFF07D47B);
    final dias = sub.diasRestantes;
    final diasLabel = dias == 0
        ? 'Hoy'
        : dias == 1
            ? '1 día'
            : '$dias días';

    return GestureDetector(
      onTap: () => _openDetail(context, sub),
      child: Container(
        width: 145,
        padding: const EdgeInsets.all(DesignTokens.s12),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(DesignTokens.rL),
          border: Border.all(
            color: sub.isUrgent
                ? DesignTokens.error.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceLogo(name: sub.nombre, size: 44),
            const SizedBox(height: DesignTokens.s8),
            Text(
              sub.precioFormateado,
              style: const TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 18,
                fontWeight: DesignTokens.wBold,
                color: Colors.white,
              ),
            ),
            Text(
              'Mensual',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    diasLabel,
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 10,
                      fontWeight: DesignTokens.wSemibold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sub.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 11,
                fontWeight: DesignTokens.wMedium,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Suscripciones vencidas ───────────────────────────────────────────────────

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
        _SectionHeader(
          title: 'SUSCRIPCIONES VENCIDAS',
          trailing: Icon(Icons.warning_amber_rounded,
              color: DesignTokens.error, size: 16),
        ),
        const SizedBox(height: DesignTokens.s12),
        ...vencidas.map((sub) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.s8),
              child: GestureDetector(
                onTap: () => _openDetail(context, sub),
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.s12),
                  decoration: BoxDecoration(
                    color: DesignTokens.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(DesignTokens.rL),
                    border: Border.all(
                        color: DesignTokens.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      ServiceLogo(name: sub.nombre, size: 40),
                      const SizedBox(width: DesignTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sub.nombre,
                                style: const TextStyle(
                                  fontFamily: DesignTokens.fontFamily,
                                  fontSize: 13,
                                  fontWeight: DesignTokens.wSemibold,
                                  color: Colors.white,
                                )),
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
                        sub.precioFormateado,
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

// ─── Servicios más populares ──────────────────────────────────────────────────

const List<String> _kPopularServices = [
  'Spotify',
  'Netflix',
  'Disney+',
  'YouTube Premium',
  'Amazon Prime',
  'Max',
  'Paramount+',
  'Apple TV+',
];

class _ServiciosPopularesRow extends StatelessWidget {
  final SubscriptionState state;
  final BuildContext context;
  const _ServiciosPopularesRow({required this.state, required this.context});

  @override
  Widget build(BuildContext context) {
    final existing = state.allSubscriptions
        .map((s) => s.nombre.toLowerCase())
        .toSet();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kPopularServices.length,
        separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.s10),
        itemBuilder: (_, i) {
          final service = _kPopularServices[i];
          final hasIt = existing.contains(service.toLowerCase());
          return _PopularServiceCard(
            name: service,
            hasIt: hasIt,
            onAdd: hasIt
                ? null
                : () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            AddSubscriptionPage(preselectedService: service),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: DesignTokens.animNormal,
                      ),
                    ),
          );
        },
      ),
    );
  }
}

class _PopularServiceCard extends StatelessWidget {
  final String name;
  final bool hasIt;
  final VoidCallback? onAdd;
  const _PopularServiceCard({
    required this.name,
    required this.hasIt,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final color = serviceBrandColor(name);
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.s8, vertical: DesignTokens.s10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ServiceLogo(name: name, size: 40),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 10,
                color: Colors.white,
                fontWeight: DesignTokens.wMedium,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: hasIt
                    ? const Color(0xFF07D47B).withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasIt
                      ? const Color(0xFF07D47B).withValues(alpha: 0.5)
                      : color.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                hasIt ? Icons.check_rounded : Icons.add_rounded,
                size: 14,
                color: hasIt ? const Color(0xFF07D47B) : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Aumento de precios horizontal ───────────────────────────────────────────

class _AumentoPreciosRow extends StatelessWidget {
  final SubscriptionState state;
  final BuildContext context;
  const _AumentoPreciosRow({required this.state, required this.context});

  @override
  Widget build(BuildContext context) {
    final items = state.allSubscriptions
        .where((s) =>
            s.precioOriginal != null && s.precioOriginal! > s.precioActual)
        .toList()
      ..sort((a, b) {
        final ia = (a.precioOriginal! - a.precioActual) / a.precioActual;
        final ib = (b.precioOriginal! - b.precioActual) / b.precioActual;
        return ib.compareTo(ia);
      });

    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.s10),
        itemBuilder: (_, i) {
          final sub = items[i];
          final pct =
              ((sub.precioOriginal! - sub.precioActual) / sub.precioActual * 100)
                  .toStringAsFixed(0);
          return GestureDetector(
            onTap: () => _openDetail(context, sub),
            child: Container(
              width: 150,
              padding: const EdgeInsets.all(DesignTokens.s12),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(DesignTokens.rL),
                border: Border.all(
                  color: DesignTokens.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ServiceLogo(name: sub.nombre, size: 36),
                      const SizedBox(width: DesignTokens.s8),
                      Expanded(
                        child: Text(
                          sub.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 12,
                            fontWeight: DesignTokens.wSemibold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.precioFormateado,
                            style: TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                          Text(
                            '${sub.currencySymbol}${sub.precioOriginal!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 13,
                              fontWeight: DesignTokens.wBold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: DesignTokens.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  DesignTokens.warning.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '+$pct%',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 11,
                            fontWeight: DesignTokens.wBold,
                            color: DesignTokens.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── FABs ─────────────────────────────────────────────────────────────────────

class _DashboardFABs extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onSyncGmail;

  const _DashboardFABs({required this.onAdd, required this.onSyncGmail});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'fab_gmail',
          onPressed: onSyncGmail,
          backgroundColor: _kCard,
          foregroundColor: Colors.white,
          tooltip: 'Sincronizar Gmail',
          elevation: 2,
          child: const Icon(Icons.email_outlined),
        ),
        const SizedBox(height: DesignTokens.s12),
        FloatingActionButton.extended(
          heroTag: 'fab_add',
          onPressed: onAdd,
          backgroundColor: const Color(0xFF4F6BFF),
          foregroundColor: Colors.white,
          elevation: 4,
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
