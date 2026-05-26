import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kCard = Color(0xFF3B4792);
const Color _kGreen = Color(0xFF07D47B);

class AcercaDePage extends StatelessWidget {
  const AcercaDePage({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Acerca de PODA',
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
          const SizedBox(height: DesignTokens.s24),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFF4F6BFF).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4F6BFF).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.content_cut_rounded,
                size: 44,
                color: Color(0xFF4F6BFF),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.s16),
          const Center(
            child: Text(
              'PODA',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 28,
                fontWeight: DesignTokens.wBold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Versión 1.0.0',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.s32),
          _InfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Descripción',
            body:
                'PODA es tu gestor inteligente de suscripciones. Te ayuda a visualizar, controlar y optimizar todos tus servicios de suscripción en un solo lugar.',
          ),
          const SizedBox(height: DesignTokens.s12),
          _InfoCard(
            icon: Icons.shield_outlined,
            title: 'Privacidad',
            body:
                'Tu información se almacena de forma segura. Los datos de tus suscripciones solo son accesibles por ti.',
          ),
          const SizedBox(height: DesignTokens.s12),
          _InfoCard(
            icon: Icons.build_outlined,
            title: 'Desarrollado por',
            body: 'Equipo PODA',
          ),
          const SizedBox(height: DesignTokens.s32),
          Center(
            child: Text(
              '© 2025 PODA. Todos los derechos reservados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.s16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 20),
          const SizedBox(width: DesignTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 13,
                    fontWeight: DesignTokens.wSemibold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.65),
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
