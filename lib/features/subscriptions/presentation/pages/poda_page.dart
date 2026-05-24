import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';

const Color _kBg = Color(0xFF030B3F);

/// Pantalla PODA — placeholder hasta implementación completa.
class PodaPage extends StatelessWidget {
  const PodaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.s32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.content_cut_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: DesignTokens.s24),
                const Text(
                  'PODA',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 32,
                    fontWeight: DesignTokens.wExtraBold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: DesignTokens.s16),
                Text(
                  'Próximamente: recomendaciones inteligentes para cancelar suscripciones que no usas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 15,
                    fontWeight: DesignTokens.wRegular,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
