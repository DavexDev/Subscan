import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/auth/auth_provider.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);

class InformacionPersonalPage extends ConsumerWidget {
  const InformacionPersonalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final name = user?.displayName ?? 'Sin nombre';
    final email = user?.email ?? 'Sin correo';

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Información personal',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 20,
            fontWeight: DesignTokens.wBold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.s16),
        children: [
          const SizedBox(height: DesignTokens.s8),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFF6B7280),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 36,
                    fontWeight: DesignTokens.wBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.s24),
          _InfoField(label: 'Nombre completo', value: name),
          const SizedBox(height: DesignTokens.s12),
          _InfoField(label: 'Correo electrónico', value: email),
          const SizedBox(height: DesignTokens.s12),
          _InfoField(label: 'Proveedor', value: _providerLabel(user?.providerData)),
          const SizedBox(height: DesignTokens.s32),
          Container(
            padding: const EdgeInsets.all(DesignTokens.s16),
            decoration: BoxDecoration(
              color: _kCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(DesignTokens.rL),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: DesignTokens.s8),
                Expanded(
                  child: Text(
                    'Para editar tu información personal, actualiza tu perfil desde la cuenta de Google o el proveedor con el que iniciaste sesión.',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _providerLabel(List<dynamic>? providers) {
    if (providers == null || providers.isEmpty) return 'Desconocido';
    final id = providers.first.providerId as String? ?? '';
    if (id.contains('google')) return 'Google';
    if (id.contains('apple')) return 'Apple';
    if (id.contains('password')) return 'Email y contraseña';
    return id;
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.s16,
        vertical: DesignTokens.s12,
      ),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: DesignTokens.wMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 15,
              color: Colors.white,
              fontWeight: DesignTokens.wMedium,
            ),
          ),
        ],
      ),
    );
  }
}
