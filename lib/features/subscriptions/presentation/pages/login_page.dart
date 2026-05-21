import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Entry animation
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Floating blob animation
  late AnimationController _blobController;
  late Animation<double> _blobAnim;

  // Form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
    ));

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _blobAnim =
        CurvedAnimation(parent: _blobController, curve: Curves.easeInOut);

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _blobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) => const DashboardPage(),
        transitionsBuilder: (ctx, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: DesignTokens.animNormal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Dark background ───────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF080818),
                  Color(0xFF0D0B2A),
                ],
              ),
            ),
          ),

          // ── Teal blob top-right ───────────────────────────────────────────
          AnimatedBuilder(
            animation: _blobAnim,
            builder: (ctx, child) {
              final scale = 1.0 + _blobAnim.value * 0.08;
              return Positioned(
                top: -size.width * 0.3 + _blobAnim.value * 15,
                right: -size.width * 0.3,
                child: Transform.scale(
                  scale: scale,
                  child: _Blob(size: size.width * 0.85),
                ),
              );
            },
          ),

          // ── Main content ──────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      // Floating app icons
                      _FloatingIconsRow(blobAnim: _blobAnim),

                      const SizedBox(height: 20),

                      // Person illustration
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A3E),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade300.withValues(alpha: 0.2),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: Colors.blue.shade300,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Bienvenido a PODA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 28,
                          fontWeight: DesignTokens.wBold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Controla tus suscripciones fácilmente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 15,
                          fontWeight: DesignTokens.wMedium,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email field
                      _DarkTextField(
                        controller: _emailController,
                        hint: 'Email...',
                        prefixIcon: Icons.search_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 14),

                      // Password field
                      _DarkTextField(
                        controller: _passwordController,
                        hint: 'Contraseña...',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixTap: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),

                      const SizedBox(height: 10),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              fontFamily: DesignTokens.fontFamily,
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Iniciar Sesión button
                      _SignInButton(
                        loading: _loading,
                        onTap: _handleSignIn,
                      ),

                      const SizedBox(height: 16),

                      // Problems text
                      Text(
                        '¿Tienes problemas al iniciar sesión?',
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider with "o"
                      _OrDivider(),

                      const SizedBox(height: 20),

                      // Google button
                      _GoogleButton(onTap: _handleSignIn),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Teal blob ────────────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final double size;
  const _Blob({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF00B4A0).withValues(alpha: 0.3),
            const Color(0xFF00B4A0).withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ─── Floating icons row ───────────────────────────────────────────────────────

class _FloatingIconsRow extends StatelessWidget {
  final Animation<double> blobAnim;
  const _FloatingIconsRow({required this.blobAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: blobAnim,
      builder: (ctx, child) {
        final v = blobAnim.value;
        return SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniIcon(
                icon: Icons.play_circle_filled_rounded,
                color: const Color(0xFFFF0000),
                offset: v * 6,
              ),
              const SizedBox(width: 12),
              _MiniIcon(
                icon: Icons.star_rounded,
                color: const Color(0xFF00B3E3),
                offset: -v * 8,
              ),
              const SizedBox(width: 12),
              _MiniIcon(
                icon: Icons.movie_rounded,
                color: const Color(0xFFE50914),
                offset: v * 5,
              ),
              const SizedBox(width: 12),
              _MiniIcon(
                icon: Icons.music_note_rounded,
                color: const Color(0xFF1DB954),
                offset: -v * 7,
              ),
              const SizedBox(width: 12),
              _MiniIcon(
                icon: Icons.hd_rounded,
                color: const Color(0xFF0070F3),
                offset: v * 9,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double offset;

  const _MiniIcon({
    required this.icon,
    required this.color,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A3E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// ─── Dark text field ──────────────────────────────────────────────────────────

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType keyboardType;

  const _DarkTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF13132A),
        borderRadius: BorderRadius.circular(DesignTokens.rM),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 15,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.white.withValues(alpha: 0.35),
            size: 20,
          ),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(
                    suffixIcon,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ─── Sign-in button ───────────────────────────────────────────────────────────

class _SignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _SignInButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF4F46E5),
            ],
          ),
          borderRadius: BorderRadius.circular(DesignTokens.rM),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 16,
                    fontWeight: DesignTokens.wBold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Divider with "o" ─────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.12),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'o',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.12),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

// ─── Google button ────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.rM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // G logo
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Google',
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 16,
                fontWeight: DesignTokens.wSemibold,
                color: Color(0xFF1F1F1F),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
