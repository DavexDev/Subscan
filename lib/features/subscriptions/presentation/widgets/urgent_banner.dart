import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/models/subscription.dart';

/// Banner animado que muestra las suscripciones urgentes en el tope del dashboard.
class UrgentBanner extends StatefulWidget {
  final List<Subscription> urgentes;

  const UrgentBanner({super.key, required this.urgentes});

  @override
  State<UrgentBanner> createState() => _UrgentBannerState();
}

class _UrgentBannerState extends State<UrgentBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urgentes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        DesignTokens.s16,
        DesignTokens.s8,
        DesignTokens.s16,
        DesignTokens.s4,
      ),
      decoration: BoxDecoration(
        gradient: DesignTokens.urgentGradient,
        borderRadius: BorderRadius.circular(DesignTokens.rL),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.error.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.s16),
        child: Row(
          children: [
            // Ícono pulsante
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.s12),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.urgentes.length == 1
                        ? '¡${widget.urgentes.first.nombre} vence pronto!'
                        : '${widget.urgentes.length} suscripciones urgentes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: DesignTokens.wBold,
                      fontFamily: DesignTokens.fontFamily,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.s2),
                  Text(
                    widget.urgentes.length == 1
                        ? 'Renueva en ${widget.urgentes.first.diasRestantes} ${widget.urgentes.first.diasRestantes == 1 ? 'día' : 'días'}'
                        : widget.urgentes
                            .map((s) => s.nombre)
                            .join(', '),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontFamily: DesignTokens.fontFamily,
                      fontWeight: DesignTokens.wMedium,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Badge con cantidad
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.s8,
                vertical: DesignTokens.s4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(DesignTokens.rFull),
              ),
              child: Text(
                '${widget.urgentes.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: DesignTokens.wBold,
                  fontFamily: DesignTokens.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
