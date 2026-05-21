import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/login_page.dart';

// ─── Entry Point ─────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Floating animation for illustration blobs
  late AnimationController _floatController;
  late AnimationController _blobController;
  late Animation<double> _floatAnim;
  late Animation<double> _blobAnim;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _floatAnim =
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut);
    _blobAnim =
        CurvedAnimation(parent: _blobController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: DesignTokens.animNormal,
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: DesignTokens.animNormal,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, ctx, child) => const LoginPage(),
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
      body: Stack(
        children: [
          // ── Dark navy background ──────────────────────────────────────────
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
          Positioned(
            top: -size.width * 0.25,
            right: -size.width * 0.25,
            child: AnimatedBuilder(
              animation: _blobAnim,
              builder: (context, _) {
                final scale = 1.0 + _blobAnim.value * 0.08;
                return Transform.translate(
                  offset: Offset(0, _blobAnim.value * 20),
                  child: Transform.scale(
                    scale: scale,
                    child: _TealBlob(size: size.width * 0.8),
                  ),
                );
              },
            ),
          ),

          // ── Back button (pages 1 & 2) ─────────────────────────────────────
          if (_currentPage > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: IconButton(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 22),
              ),
            ),

          // ── PageView ──────────────────────────────────────────────────────
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _OnboardingScreen1(floatAnim: _floatAnim),
                _OnboardingScreen2(floatAnim: _floatAnim),
                _OnboardingScreen3(floatAnim: _floatAnim),
              ],
            ),
          ),

          // ── Bottom nav overlay ────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: _BottomNavBar(
                currentPage: _currentPage,
                onSkip: _goToLogin,
                onNext: _goToNext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Teal blob widget ─────────────────────────────────────────────────────────

class _TealBlob extends StatelessWidget {
  final double size;
  const _TealBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF00B4A0).withValues(alpha: 0.35),
            const Color(0xFF00B4A0).withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const _BottomNavBar({
    required this.currentPage,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == 2;
    final nextLabel = isLastPage ? 'VAMOS' : 'SIGUIENTE';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => _DotIndicator(active: i == currentPage)),
          ),
          const SizedBox(height: 28),

          // OMITIR + SIGUIENTE/VAMOS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // OMITIR – plain white text
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'OMITIR',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 14,
                    fontWeight: DesignTokens.wSemibold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // SIGUIENTE / VAMOS – purple rounded rectangle
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9243FF),
                    borderRadius: BorderRadius.circular(DesignTokens.rFull),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9243FF).withValues(alpha: 0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    nextLabel,
                    style: const TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 14,
                      fontWeight: DesignTokens.wBold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool active;
  const _DotIndicator({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesignTokens.animFast,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFF444466),
        borderRadius: BorderRadius.circular(DesignTokens.rFull),
      ),
    );
  }
}

// ─── Floating icon chip ───────────────────────────────────────────────────────

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double left;
  final double top;
  final double floatOffset;

  const _FloatingIcon({
    required this.icon,
    required this.color,
    this.size = 48,
    required this.left,
    required this.top,
    this.floatOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top + floatOffset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A3E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

// ─── Screen 1 ────────────────────────────────────────────────────────────────

class _OnboardingScreen1 extends StatelessWidget {
  final Animation<double> floatAnim;
  const _OnboardingScreen1({required this.floatAnim});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final illustrationHeight = size.height * 0.45;

    return Column(
      children: [
        // Illustration area
        SizedBox(
          height: illustrationHeight,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: floatAnim,
                builder: (context, _) {
                  final v = floatAnim.value;
                  return Stack(
                    children: [
                      // Netflix
                      _FloatingIcon(
                        icon: Icons.movie_rounded,
                        color: const Color(0xFFE50914),
                        size: 56,
                        left: size.width * 0.12,
                        top: illustrationHeight * 0.25,
                        floatOffset: v * 12,
                      ),
                      // Spotify
                      _FloatingIcon(
                        icon: Icons.music_note_rounded,
                        color: const Color(0xFF1DB954),
                        size: 64,
                        left: size.width * 0.55,
                        top: illustrationHeight * 0.15,
                        floatOffset: -v * 15,
                      ),
                      // Chat (Skype)
                      _FloatingIcon(
                        icon: Icons.chat_rounded,
                        color: const Color(0xFF00AFF0),
                        size: 50,
                        left: size.width * 0.3,
                        top: illustrationHeight * 0.55,
                        floatOffset: v * 8,
                      ),
                      // Drive
                      _FloatingIcon(
                        icon: Icons.cloud_rounded,
                        color: const Color(0xFF4285F4),
                        size: 52,
                        left: size.width * 0.65,
                        top: illustrationHeight * 0.52,
                        floatOffset: -v * 10,
                      ),
                      // Small decorative orb
                      Positioned(
                        left: size.width * 0.38,
                        top: illustrationHeight * 0.28,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9243FF).withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: size.width * 0.22,
                        top: illustrationHeight * 0.6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00B4A0),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Text content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demasiadas\nsuscripciones',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 40,
                    fontWeight: DesignTokens.wExtraBold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Controla todos tus pagos y evita gastos innecesarios cada mes.',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 20,
                    fontWeight: DesignTokens.wMedium,
                    color: Color(0xFF909090),
                    height: 1.4,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),

        // Space for bottom nav
        const SizedBox(height: 120),
      ],
    );
  }
}

// ─── Screen 2 ────────────────────────────────────────────────────────────────

class _OnboardingScreen2 extends StatelessWidget {
  final Animation<double> floatAnim;
  const _OnboardingScreen2({required this.floatAnim});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final illustrationHeight = size.height * 0.45;

    return Column(
      children: [
        // Illustration area with floating icons + price card
        SizedBox(
          height: illustrationHeight,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: floatAnim,
                builder: (context, _) {
                  final v = floatAnim.value;
                  return Stack(
                    children: [
                      // Background icons
                      _FloatingIcon(
                        icon: Icons.movie_rounded,
                        color: const Color(0xFFE50914),
                        size: 44,
                        left: size.width * 0.08,
                        top: illustrationHeight * 0.12,
                        floatOffset: v * 10,
                      ),
                      _FloatingIcon(
                        icon: Icons.music_note_rounded,
                        color: const Color(0xFF1DB954),
                        size: 40,
                        left: size.width * 0.68,
                        top: illustrationHeight * 0.08,
                        floatOffset: -v * 12,
                      ),
                      _FloatingIcon(
                        icon: Icons.photo_camera_rounded,
                        color: const Color(0xFFFF6B35),
                        size: 36,
                        left: size.width * 0.78,
                        top: illustrationHeight * 0.42,
                        floatOffset: v * 8,
                      ),

                      // Price card overlay
                      Positioned(
                        left: size.width * 0.06,
                        top: illustrationHeight * 0.3 - v * 5,
                        right: size.width * 0.06,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13132A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Column(
                            children: [
                              _PriceRow(
                                icon: Icons.movie_rounded,
                                iconColor: Color(0xFFE50914),
                                name: 'Netflix',
                                price: '\$12.99',
                              ),
                              SizedBox(height: 10),
                              _PriceRow(
                                icon: Icons.music_note_rounded,
                                iconColor: Color(0xFF1DB954),
                                name: 'Spotify',
                                price: '\$9.14',
                              ),
                              SizedBox(height: 10),
                              _PriceRow(
                                icon: Icons.cloud_rounded,
                                iconColor: Color(0xFF4285F4),
                                name: 'iCloud',
                                price: '\$13.59',
                              ),
                              SizedBox(height: 10),
                              _PriceRow(
                                icon: Icons.brush_rounded,
                                iconColor: Color(0xFF7C3AED),
                                name: 'Canva',
                                price: '\$6.99',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Text content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analizamos\ntus gastos',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 40,
                    fontWeight: DesignTokens.wExtraBold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PODA detecta renovaciones automáticas y servicios que casi no utilizas.',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 20,
                    fontWeight: DesignTokens.wMedium,
                    color: Color(0xFF909090),
                    height: 1.4,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),

        // Space for bottom nav
        const SizedBox(height: 120),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String price;

  const _PriceRow({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: 14,
              fontWeight: DesignTokens.wMedium,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontSize: 14,
            fontWeight: DesignTokens.wBold,
            color: Color(0xFF00B4A0),
          ),
        ),
      ],
    );
  }
}

// ─── Screen 3 ────────────────────────────────────────────────────────────────

class _OnboardingScreen3 extends StatelessWidget {
  final Animation<double> floatAnim;
  const _OnboardingScreen3({required this.floatAnim});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final illustrationHeight = size.height * 0.45;

    return Column(
      children: [
        // Illustration – icon chips being "cut"
        SizedBox(
          height: illustrationHeight,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: floatAnim,
                builder: (context, _) {
                  final v = floatAnim.value;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Row of "surviving" app icon chips
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _AppChip(
                              icon: Icons.movie_rounded,
                              color: const Color(0xFFE50914),
                              label: 'Netflix',
                              floatOffset: v * 8,
                            ),
                            _AppChip(
                              icon: Icons.music_note_rounded,
                              color: const Color(0xFF1DB954),
                              label: 'Spotify',
                              floatOffset: -v * 6,
                            ),
                            _AppChip(
                              icon: Icons.cloud_rounded,
                              color: const Color(0xFF4285F4),
                              label: 'Drive',
                              floatOffset: v * 10,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Scissors / cut line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.content_cut_rounded,
                              color: Color(0xFF9243FF),
                              size: 28,
                            ),
                            Expanded(
                              child: CustomPaint(
                                painter: _DashedLinePainter(),
                                child: const SizedBox(height: 2),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Row of "cut" / faded chips
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _AppChip(
                              icon: Icons.fitness_center_rounded,
                              color: const Color(0xFF666666),
                              label: 'Gym',
                              faded: true,
                              floatOffset: -v * 7,
                            ),
                            _AppChip(
                              icon: Icons.tv_rounded,
                              color: const Color(0xFF666666),
                              label: 'Cable',
                              faded: true,
                              floatOffset: v * 5,
                            ),
                            _AppChip(
                              icon: Icons.newspaper_rounded,
                              color: const Color(0xFF666666),
                              label: 'News',
                              faded: true,
                              floatOffset: -v * 9,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Text content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 40,
                      fontWeight: DesignTokens.wExtraBold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    children: [
                      TextSpan(text: 'Poda'),
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Color(0xFF9243FF)),
                      ),
                      TextSpan(text: '\nlo innecesario'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ahorra dinero cancelando suscripciones que ya no aportan valor.',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 20,
                    fontWeight: DesignTokens.wMedium,
                    color: Color(0xFF909090),
                    height: 1.4,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),

        // Space for bottom nav
        const SizedBox(height: 120),
      ],
    );
  }
}

class _AppChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool faded;
  final double floatOffset;

  const _AppChip({
    required this.icon,
    required this.color,
    required this.label,
    this.faded = false,
    this.floatOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, floatOffset),
      child: Opacity(
        opacity: faded ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: faded
                ? const Color(0xFF1A1A3E).withValues(alpha: 0.5)
                : const Color(0xFF1A1A3E),
            borderRadius: BorderRadius.circular(DesignTokens.rFull),
            border: Border.all(
              color: color.withValues(alpha: faded ? 0.15 : 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontSize: 13,
                  fontWeight: DesignTokens.wMedium,
                  color: faded ? Colors.grey : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dashed line painter ──────────────────────────────────────────────────────

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9243FF).withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(math.min(startX + dashWidth, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
