import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/auth/auth_provider.dart';
import 'package:subscan/features/subscriptions/providers/subscription_notifier_provider.dart';
import 'login_page.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kGreen = Color(0xFF07D47B);

/// Pantalla de perfil y preferencias del usuario.
class MiCuentaPage extends ConsumerWidget {
  const MiCuentaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(subscriptionNotifierProvider);

    final gastoMensual = state.allSubscriptions.fold<double>(
      0,
      (s, sub) => s + sub.precioActual,
    );
    final totalSubs = state.allSubscriptions.length;
    final ahorros = state.allSubscriptions.fold<double>(
      0,
      (s, sub) =>
          s +
          ((sub.precioOriginal != null && sub.precioOriginal! > sub.precioActual)
              ? sub.precioOriginal! - sub.precioActual
              : 0),
    );

    final displayName = user?.displayName ?? 'Usuario';
    final displayEmail = user?.email ?? '';

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mi cuenta',
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
                'Gestiona tu perfil y preferencias',
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
          // Profile row
          _ProfileRow(name: displayName, email: displayEmail),
          const SizedBox(height: DesignTokens.s20),
          // Stats card
          _StatsCard(
            gastoMensual: gastoMensual,
            totalSubs: totalSubs,
            ahorros: ahorros,
          ),
          const SizedBox(height: DesignTokens.s20),
          // Settings menu
          _SettingsMenu(),
          const SizedBox(height: DesignTokens.s20),
          // Logout button
          _LogoutButton(
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── Profile Row ──────────────────────────────────────────────────────────────

class _ProfileRow extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileRow({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF6B7280),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 28,
                fontWeight: DesignTokens.wBold,
                color: Colors.white,
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
                name,
                style: const TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 18,
                  fontWeight: DesignTokens.wBold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final double gastoMensual;
  final int totalSubs;
  final double ahorros;

  const _StatsCard({
    required this.gastoMensual,
    required this.totalSubs,
    required this.ahorros,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'Gasto mensual',
                    value: 'Q${gastoMensual.toStringAsFixed(2)}',
                  ),
                ),
                _VDiv(),
                Expanded(
                  child: _StatColumn(
                    label: 'Suscripciones',
                    value: '$totalSubs Activas',
                  ),
                ),
                _VDiv(),
                Expanded(
                  child: _StatColumn(
                    label: 'Ahorros totales',
                    value: 'Q${ahorros.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.s12),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: DesignTokens.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_down_rounded,
                    size: 16,
                    color: _kGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '12% menos este mes',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 12,
                      fontWeight: DesignTokens.wMedium,
                      color: _kGreen,
                    ),
                  ),
                ],
              ),
              Text(
                'Este mes',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

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
          ),
        ),
        const SizedBox(height: DesignTokens.s4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 14,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
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

// ─── Settings Menu ────────────────────────────────────────────────────────────

class _SettingsMenu extends StatelessWidget {
  static const List<_MenuItem> _items = [
    _MenuItem(
      icon: Icons.person_outline_rounded,
      title: 'Información personal',
      subtitle: 'Actualizar datos personales - información personal',
    ),
    _MenuItem(
      icon: Icons.credit_card_rounded,
      title: 'Métodos de pago',
      subtitle: 'Administra tus tarjetas y métodos',
    ),
    _MenuItem(
      icon: Icons.notifications_none_rounded,
      title: 'Notificaciones',
      subtitle: 'Configura tus preferencias',
    ),
    _MenuItem(
      icon: Icons.lock_outline_rounded,
      title: 'Seguridad',
      subtitle: 'Contraseña, 2FA y sesiones',
    ),
    _MenuItem(
      icon: Icons.download_rounded,
      title: 'Descargar reportes',
      subtitle: 'Descarga tus reportes de gastos',
    ),
    _MenuItem(
      icon: Icons.help_outline_rounded,
      title: 'Centro de ayuda',
      subtitle: 'Preguntas frecuentes y soporte',
    ),
    _MenuItem(
      icon: Icons.info_outline_rounded,
      title: 'Acerca de PODA',
      subtitle: 'Versión 1.0.0',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final isLast = i == _items.length - 1;
          return _MenuRow(item: item, isLast: isLast);
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _MenuRow extends StatelessWidget {
  final _MenuItem item;
  final bool isLast;

  const _MenuRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          borderRadius: isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(DesignTokens.rL),
                  bottomRight: Radius.circular(DesignTokens.rL),
                )
              : BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.s16,
              vertical: DesignTokens.s12,
            ),
            child: Row(
              children: [
                Icon(item.icon, color: Colors.white, size: 22),
                const SizedBox(width: DesignTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 14,
                          fontWeight: DesignTokens.wMedium,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.12),
            indent: DesignTokens.s16,
            endIndent: DesignTokens.s16,
          ),
      ],
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.logout_rounded,
          color: Color(0xFFD7434B),
        ),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 16,
            fontWeight: DesignTokens.wSemibold,
            color: Color(0xFFD7434B),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC50000),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.rL),
          ),
        ),
      ),
    );
  }
}
