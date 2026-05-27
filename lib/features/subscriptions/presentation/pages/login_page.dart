import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/core/widgets/service_logo.dart';
import 'package:subscan/features/auth/auth_provider.dart';
import 'package:subscan/features/subscriptions/presentation/pages/main_shell.dart';

// ── Colores exactos del Figma ─────────────────────────────────────────────────
const Color _kBg = Color(0xFF030B3F);     // fondo oscuro
const Color _kCard = Color(0xFF111C63);   // tarjeta inferior
const Color _kBlue = Color(0xFF3461FD);   // botón primario
const Color _kInputBg = Color(0xFFF4F7FB); // campos de texto
const Color _kHint = Color(0xFF8E8D8D);   // placeholder
const Color _kLink = Color(0xFF94A3B8);   // links de ayuda
const Color _kInputBorder = Color(0xFFE2E8F0);

// ─────────────────────────────────────────────────────────────────────────────

/// Página de inicio de sesión — PODA
/// Diseño fiel al Figma: fondo navy + tarjeta azul oscuro con campos email/pass,
/// botón principal + Google alternativo.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _loading = false;
  String? _errorMsg;
  // false = login, true = registro
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Navegación ───────────────────────────────────────────────────────────

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context2, anim, secondary) => const MainShell(),
        transitionsBuilder: (context2, anim, secondary, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: DesignTokens.animNormal,
      ),
    );
  }

  // ── Acciones de auth ─────────────────────────────────────────────────────

  Future<void> _submitEmailPass() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      if (_isRegisterMode) {
        await auth.registerWithEmail(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
      } else {
        await auth.signInWithEmail(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
      }
      if (mounted) _goToDashboard();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMsg = _friendlyError(e.toString());
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) _goToDashboard();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMsg = e.toString().contains('cancelled')
              ? null
              : 'No se pudo iniciar sesión con Google';
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMsg = 'Ingresa tu email primero para recuperar contraseña');
      return;
    }
    setState(() => _errorMsg = null);
    try {
      await ref.read(authServiceProvider).resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email de recuperación enviado a $email ✅'),
            backgroundColor: const Color(0xFF07D47B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      setState(() => _errorMsg = 'No se pudo enviar el email de recuperación');
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Email o contraseña incorrectos';
    }
    if (raw.contains('user-not-found')) {
      return 'No existe cuenta con ese email. ¿Quieres crear una?';
    }
    if (raw.contains('email-already-in-use')) {
      return 'Ya existe una cuenta con este email';
    }
    if (raw.contains('weak-password')) {
      return 'La contraseña es muy corta (mínimo 6 caracteres)';
    }
    if (raw.contains('invalid-email')) return 'El formato del email no es válido';
    if (raw.contains('too-many-requests')) {
      return 'Demasiados intentos. Espera unos minutos';
    }
    if (raw.contains('network')) return 'Sin conexión a internet';
    return 'Error al iniciar sesión. Intenta de nuevo';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Sección superior — branding
          Expanded(child: _TopSection()),
          // Tarjeta inferior — formulario
          _LoginCard(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            passCtrl: _passCtrl,
            obscurePass: _obscurePass,
            loading: _loading,
            errorMsg: _errorMsg,
            isRegisterMode: _isRegisterMode,
            onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
            onSubmit: _submitEmailPass,
            onGoogle: _signInWithGoogle,
            onForgotPassword: _forgotPassword,
            onToggleMode: () => setState(() {
              _isRegisterMode = !_isRegisterMode;
              _errorMsg = null;
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sección superior: decoración, logos, branding
// ─────────────────────────────────────────────────────────────────────────────

class _TopSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Ola decorativa superior (Vector 2 del Figma)
        Positioned(
          top: 0, left: 0, right: 0,
          child: CustomPaint(
            painter: _WavePainter(),
            child: const SizedBox(height: 180),
          ),
        ),
        // Contenido principal
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Logo + nombre PODA
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.content_cut_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PODA',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 22,
                        fontWeight: DesignTokens.wExtraBold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Logos de servicios populares
                _ServiceLogosRow(),
                const SizedBox(height: 14),
                // Titular principal
                const Text(
                  'Bienvenido a PODA',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 22,
                    fontWeight: DesignTokens.wExtraBold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                // Subtítulo
                Text(
                  'Controla tus suscripciones fácilmente.',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 14,
                    fontWeight: DesignTokens.wSemibold,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Row de logos de servicios ────────────────────────────────────────────────

class _ServiceLogosRow extends StatelessWidget {
  static const _services = [
    'Netflix',
    'Spotify',
    'YouTube',
    'Disney+',
    'Amazon Prime',
    'Max',
    'Twitch',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _services.asMap().entries.map((e) {
        final i = e.key;
        final name = e.value;
        return Transform.translate(
          offset: Offset(i * -10.0, 0),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kBg, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: ServiceLogo(name: name, size: 44),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de login: #111C63, bordes redondeados arriba (r=68)
// ─────────────────────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscurePass;
  final bool loading;
  final String? errorMsg;
  final bool isRegisterMode;
  final VoidCallback onTogglePass;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onForgotPassword;
  final VoidCallback onToggleMode;

  const _LoginCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscurePass,
    required this.loading,
    required this.errorMsg,
    required this.isRegisterMode,
    required this.onTogglePass,
    required this.onSubmit,
    required this.onGoogle,
    required this.onForgotPassword,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(68),
        ),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 28,
          right: 28,
          top: 36,
          bottom: bottomInset > 0 ? bottomInset + 20 : 36,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título del formulario
              Text(
                isRegisterMode ? 'Crear cuenta' : 'Iniciar Sesión',
                style: const TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 20,
                  fontWeight: DesignTokens.wBold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isRegisterMode
                    ? 'Ingresa tus datos para registrarte'
                    : 'Ingresa tus credenciales para continuar',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 24),

              // ── Campo Email ───────────────────────────────────────────────
              _InputField(
                controller: emailCtrl,
                hintText: 'Email...',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.alternate_email_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu email';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Campo Contraseña ──────────────────────────────────────────
              _InputField(
                controller: passCtrl,
                hintText: 'Contraseña...',
                obscureText: obscurePass,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: GestureDetector(
                  onTap: onTogglePass,
                  child: Icon(
                    obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _kHint,
                    size: 20,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                  if (isRegisterMode && v.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),

              // ── Mensaje de error ──────────────────────────────────────────
              if (errorMsg != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5223A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE5223A).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 12,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // ── Botón principal — Iniciar Sesión ──────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    disabledBackgroundColor: _kBlue.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isRegisterMode ? 'Crear cuenta' : 'Iniciar Sesión',
                          style: const TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 17,
                            fontWeight: DesignTokens.wSemibold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 22),

              // ── Divisor "O" ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'O',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 13,
                        fontWeight: DesignTokens.wMedium,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ── Botón Google ──────────────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : onGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kInputBg,
                    disabledBackgroundColor: _kInputBg.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CustomPaint(painter: _GoogleLogoPainter()),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Google',
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 15,
                          fontWeight: DesignTokens.wMedium,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ── Links de ayuda ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ¿Olvidaste contraseña?
                  GestureDetector(
                    onTap: onForgotPassword,
                    child: Text(
                      '¿Olvidaste de tu contraseña?',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 11,
                        fontWeight: DesignTokens.wBold,
                        color: _kLink,
                        decoration: TextDecoration.underline,
                        decorationColor: _kLink,
                      ),
                    ),
                  ),
                  // ¿Tienes problemas?
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El canal de soporte estará disponible próximamente.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      '¿Tienes problemas?',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 11,
                        fontWeight: DesignTokens.wBold,
                        color: _kLink,
                        decoration: TextDecoration.underline,
                        decorationColor: _kLink,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Toggle Login / Registro ───────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: onToggleMode,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      children: [
                        TextSpan(
                          text: isRegisterMode
                              ? '¿Ya tienes cuenta? '
                              : '¿No tienes cuenta? ',
                        ),
                        TextSpan(
                          text: isRegisterMode ? 'Inicia sesión' : 'Regístrate',
                          style: const TextStyle(
                            color: Color(0xFF7B9FFF),
                            fontWeight: DesignTokens.wBold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF7B9FFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget campo de input (reutilizable)
// ─────────────────────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: 14,
        color: Color(0xFF1E293B),
        fontWeight: DesignTokens.wMedium,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 13,
          color: _kHint,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: _kInputBg,
        prefixIcon: Icon(prefixIcon, size: 18, color: _kHint),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _kInputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _kBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE5223A), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE5223A), width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 11,
          color: Color(0xFFFF6B6B),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pintores personalizados
// ─────────────────────────────────────────────────────────────────────────────

/// Ola decorativa superior (Vector 2 del Figma)
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Forma ola izquierda superior
    final paint1 = Paint()
      ..color = const Color(0xFF0F1D70).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width * 0.70, 0);
    path1.quadraticBezierTo(
      size.width * 0.55, size.height * 0.6,
      size.width * 0.30, size.height * 0.85,
    );
    path1.quadraticBezierTo(
      size.width * 0.10, size.height,
      0, size.height * 0.80,
    );
    path1.close();
    canvas.drawPath(path1, paint1);

    // Forma ola derecha superior (más tenue)
    final paint2 = Paint()
      ..color = const Color(0xFF1A2E8F).withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(size.width, 0);
    path2.lineTo(size.width * 0.55, 0);
    path2.quadraticBezierTo(
      size.width * 0.72, size.height * 0.5,
      size.width * 0.90, size.height * 0.9,
    );
    path2.lineTo(size.width, size.height * 0.6);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Logo de Google pintado con CustomPainter
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Arcos de colores Google
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.8;

    // Azul
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.72),
      -1.57, // -90°
      2.80,
      false,
      paint,
    );
    // Verde
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.72),
      1.23,
      1.15,
      false,
      paint,
    );
    // Amarillo
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.72),
      2.38,
      0.85,
      false,
      paint,
    );
    // Rojo
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.72),
      3.23,
      0.87,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
