import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/dashboard_page.dart';

/// Pantalla de inicio / login de SubScan.
/// El flujo OAuth real se conecta aquí cuando esté disponible.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardPage(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: DesignTokens.animNormal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DesignTokens.headerGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.s32,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _Logo(),
                    const SizedBox(height: DesignTokens.s32),
                    _Headline(),
                    const Spacer(flex: 3),
                    _GoogleSignInButton(onTap: _navigateToDashboard),
                    const SizedBox(height: DesignTokens.s16),
                    _Disclaimer(),
                    const SizedBox(height: DesignTokens.s32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DesignTokens.rXL),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.radar_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.s20),
        const Text(
          'SubScan',
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 38,
            fontWeight: DesignTokens.wExtraBold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Controla todas tus\nsuscripciones en un lugar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 18,
            fontWeight: DesignTokens.wMedium,
            color: Colors.white.withValues(alpha: 0.90),
            height: 1.5,
          ),
        ),
        const SizedBox(height: DesignTokens.s24),
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
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignTokens.rFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
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

class _GoogleSignInButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GoogleSignInButton({required this.onTap});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _loading = false;

  Future<void> _handleTap() async {
    setState(() => _loading = true);
    // Simula delay de OAuth
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _loading = false);
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: DesignTokens.textPrimary,
          elevation: DesignTokens.e4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.rM),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DesignTokens.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleIcon(),
                  const SizedBox(width: DesignTokens.s12),
                  const Text(
                    'Continuar con Google',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 16,
                      fontWeight: DesignTokens.wSemibold,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Círculo base gris claro
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFEEEEEE));

    // Letras G en colores de Google
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5;

    paint.color = const Color(0xFF4285F4); // Azul
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.65),
      -0.5,
      2.6,
      false,
      paint,
    );
    paint.color = const Color(0xFF34A853); // Verde
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.65),
      2.1,
      1.0,
      false,
      paint,
    );
    paint.color = const Color(0xFFEA4335); // Rojo
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.65),
      3.1,
      0.8,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Al continuar aceptas los Términos de Servicio\ny la Política de Privacidad',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: 11,
        color: Colors.white.withValues(alpha: 0.55),
        height: 1.5,
      ),
    );
  }
}
