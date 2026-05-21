import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  // Controlador principal de entrada
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _logoSlideAnim;
  late Animation<Offset> _cardSlideAnim;

  // Controlador del orbe flotante
  late AnimationController _orbController;
  late Animation<double> _orbAnim;

  // Controlador de shimmer en el botón
  late AnimationController _shimmerController;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // Animación de entrada
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _logoSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    // Orbe flotante
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _orbAnim = CurvedAnimation(parent: _orbController, curve: Curves.easeInOut);

    // Shimmer en el botón
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _orbController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardPage(),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Fondo degradado oscuro ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0E1A), // casi negro
                  Color(0xFF1A1040), // índigo muy oscuro
                  Color(0xFF0D0D1F),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Orbes de luz de fondo ──────────────────────────────────────
          AnimatedBuilder(
            animation: _orbAnim,
            builder: (_, child) {
              final offset = _orbAnim.value * 30;
              return Stack(
                children: [
                  // Orbe superior izquierdo
                  Positioned(
                    top: -80 + offset,
                    left: -60,
                    child: _Orb(
                      size: size.width * 0.7,
                      color: const Color(0xFF6366F1),
                      opacity: 0.15,
                    ),
                  ),
                  // Orbe inferior derecho
                  Positioned(
                    bottom: -100 - offset,
                    right: -40,
                    child: _Orb(
                      size: size.width * 0.75,
                      color: const Color(0xFF8B5CF6),
                      opacity: 0.12,
                    ),
                  ),
                  // Orbe central pequeño
                  Positioned(
                    top: size.height * 0.35 + offset * 0.5,
                    left: size.width * 0.6,
                    child: _Orb(
                      size: 120,
                      color: const Color(0xFF06B6D4),
                      opacity: 0.08,
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Contenido principal ────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo + nombre
                  SlideTransition(
                    position: _logoSlideAnim,
                    child: const _LogoSection(),
                  ),

                  const Spacer(flex: 3),

                  // Card de inicio de sesión
                  SlideTransition(
                    position: _cardSlideAnim,
                    child: _SignInCard(
                      shimmerController: _shimmerController,
                      loading: _loading,
                      onSignIn: _handleSignIn,
                    ),
                  ),

                  const SizedBox(height: DesignTokens.s32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Orbe de luz ─────────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Orb({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

// ─── Logo ─────────────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícono con glassmorphism
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.rXL),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.radar_rounded,
              size: 52,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: DesignTokens.s20),

        // SubScan
        const Text(
          'SubScan',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 40,
            fontWeight: DesignTokens.wExtraBold,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ),

        const SizedBox(height: DesignTokens.s8),

        // Tagline
        Text(
          'Tus suscripciones, bajo control',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 15,
            fontWeight: DesignTokens.wMedium,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: DesignTokens.s24),

        // Pills de features
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FeaturePill(icon: Icons.notifications_active_outlined, label: 'Alertas'),
            const SizedBox(width: DesignTokens.s8),
            _FeaturePill(icon: Icons.email_outlined, label: 'Gmail'),
            const SizedBox(width: DesignTokens.s8),
            _FeaturePill(icon: Icons.bar_chart_rounded, label: 'Análisis'),
          ],
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.s12,
        vertical: DesignTokens.s6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(DesignTokens.rFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: DesignTokens.primaryLight),
          const SizedBox(width: DesignTokens.s4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 12,
              fontWeight: DesignTokens.wMedium,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card de Sign In con glassmorphism ───────────────────────────────────────

class _SignInCard extends StatelessWidget {
  final AnimationController shimmerController;
  final bool loading;
  final VoidCallback onSignIn;

  const _SignInCard({
    required this.shimmerController,
    required this.loading,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.s24),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.s32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.rXL),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Bienvenido',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 26,
                fontWeight: DesignTokens.wBold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: DesignTokens.s6),
            Text(
              'Inicia sesión para ver y gestionar\ntus suscripciones',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),

            const SizedBox(height: DesignTokens.s32),

            // Botón Google
            _GoogleButton(
              shimmerController: shimmerController,
              loading: loading,
              onTap: onSignIn,
            ),

            const SizedBox(height: DesignTokens.s20),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.s12,
                  ),
                  child: Text(
                    'o continúa con',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    thickness: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.s20),

            // Botón email (demo)
            _OutlineButton(
              icon: Icons.email_outlined,
              label: 'Correo electrónico',
              onTap: onSignIn,
            ),

            const SizedBox(height: DesignTokens.s24),

            // Disclaimer
            Center(
              child: Text(
                'Al continuar aceptas los Términos de Servicio\ny la Política de Privacidad de SubScan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.25),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Botón Google con shimmer ─────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final AnimationController shimmerController;
  final bool loading;
  final VoidCallback onTap;

  const _GoogleButton({
    required this.shimmerController,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedBuilder(
        animation: shimmerController,
        builder: (_, child) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.rM),
              gradient: LinearGradient(
                begin: Alignment(
                    -1.0 + shimmerController.value * 2.5, 0),
                end: Alignment(
                    0.0 + shimmerController.value * 2.5, 0),
                colors: const [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                  Color(0xFF6366F1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(DesignTokens.rXS),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: DesignTokens.wBold,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.s12),
                      const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 16,
                          fontWeight: DesignTokens.wSemibold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

// ─── Botón outline ────────────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.rM),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.6)),
            const SizedBox(width: DesignTokens.s10),
            Text(
              label,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 15,
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
