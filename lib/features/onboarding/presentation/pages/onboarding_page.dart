import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/login_page.dart';

// ─── Constantes de diseño (Figma: PODA — Mobile App UI, nodo 44:136) ─────────

const _kBg = Color(0xFF030B3F); // Fondo oscuro navy del Figma

// Gradiente de la franja diagonal (Vector 2)
const _kStripeColors = [
  Color(0xFF00B0FC), // Cyan  stop 0.0
  Color(0xFF10B381), // Teal  stop 0.5
  Color(0xFF5A4BF8), // Violet stop 1.0
];
const _kStripeStops = [0.0, 0.5, 1.0];

// Posición del bounding-box de la franja por página (px lógicos, base 390×844)
// Extraídos de absoluteBoundingBox relativo al frame en Figma.
const _kBx = [-86.0, -493.0, -874.0]; // desplazamiento x → cambia qué color es visible
const _kBy = [209.0, 218.0, 200.0];   // desplazamiento y → micro-movimiento vertical sutil

// Ancho total del path en Figma y fracción del gradiente
// (gradientHandlePosition[1].x del Figma)
const _kPathW = 1569.0;
const _kGradientFraction = 0.9273;

// ─── Datos de cada pantalla ───────────────────────────────────────────────────

class _PageData {
  final String title;
  final String body;
  final String imagePath;
  final String buttonLabel;

  const _PageData({
    required this.title,
    required this.body,
    required this.imagePath,
    required this.buttonLabel,
  });
}

const _kPages = [
  _PageData(
    title: 'Demasiadas\nsuscripciones',
    body: 'Controla todos tus pagos y evita gastos innecesarios cada mes.',
    imagePath: 'assets/images/onboarding/onb1.png',
    buttonLabel: 'SIGUIENTE',
  ),
  _PageData(
    title: 'Analizamos\ntus gastos',
    body: 'SubScan detecta renovaciones automáticas y servicios que casi no utilizas.',
    imagePath: 'assets/images/onboarding/onb2.png',
    buttonLabel: 'SIGUIENTE',
  ),
  _PageData(
    title: 'Recorta lo\ninnecesario',
    body: 'Ahorra dinero cancelando suscripciones que ya no aportan valor.',
    imagePath: 'assets/images/onboarding/onb3.png',
    buttonLabel: 'VAMOS',
  ),
];

// ─── Página principal ─────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  double _page = 0.0;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onScroll);
  }

  void _onScroll() => setState(() => _page = _ctrl.page ?? 0.0);

  @override
  void dispose() {
    _ctrl.removeListener(_onScroll);
    _ctrl.dispose();
    super.dispose();
  }

  void _toLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginPage(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: DesignTokens.animNormal,
      ),
    );
  }

  void _next() {
    final p = _ctrl.page?.round() ?? 0;
    if (p < _kPages.length - 1) {
      _ctrl.animateToPage(
        p + 1,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    } else {
      _toLogin();
    }
  }

  void _back() {
    final p = _ctrl.page?.round() ?? 1;
    _ctrl.animateToPage(
      p - 1,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // 1 ── Franja diagonal animada (el corazón de esta pantalla)
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _StripePainter(_page),
              ),
            ),
          ),
          // 2 ── Overlay que desvanece la franja hacia el navy en la mitad inferior
          //      (replica el efecto "desenfoque" del Figma)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _kBg.withValues(alpha: 0.55),
                    _kBg.withValues(alpha: 0.92),
                    _kBg,
                  ],
                  stops: const [0.20, 0.48, 0.65, 0.82],
                ),
              ),
            ),
          ),
          // 3 ── Contenido paginado (ilustración + texto)
          PageView.builder(
            controller: _ctrl,
            itemCount: _kPages.length,
            itemBuilder: (_, i) => _OnboardingScreen(
              data: _kPages[i],
              imageHeight: size.height * 0.43,
            ),
          ),
          // 4 ── Flecha atrás (solo páginas 2 y 3, posición y≈51 del Figma)
          if (_page > 0.01)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: DesignTokens.s24,
              child: AnimatedOpacity(
                opacity: (_page).clamp(0.0, 1.0),
                duration: DesignTokens.animFast,
                child: GestureDetector(
                  onTap: _back,
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          // 5 ── Navegación inferior (dots + botones)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNav(
              page: _page,
              total: _kPages.length,
              onNext: _next,
              onSkip: _toLogin,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pintor de la franja ──────────────────────────────────────────────────────
//
// La forma exacta proviene de la strokeGeometry del "Vector 2" en Figma
// (nodo 44:140 / 44:154 / 44:169). El path es idéntico en las 3 páginas;
// lo que cambia es su posición (bx, by) que se interpola entre páginas.
// Al trasladarse hacia la izquierda (bx −86 → −493 → −874), la parte
// visible del gradiente va de cyan → teal → violet.

class _StripePainter extends CustomPainter {
  final double pageValue;
  const _StripePainter(this.pageValue);

  // Path cacheado — se construye una sola vez con la geometría exacta del Figma.
  static final Path _wavePath = _buildWavePath();

  static double _lerpList(List<double> values, double t) {
    final t0 = t.clamp(0.0, values.length - 1.0);
    final i = t0.floor().clamp(0, values.length - 2);
    return lerpDouble(values[i], values[i + 1], t0 - i)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 390.0;
    final sy = size.height / 844.0;

    // Offset del origen del path en coordenadas de pantalla
    final bx = _lerpList(_kBx, pageValue) * sx;
    final by = _lerpList(_kBy, pageValue) * sy;

    // Transforma el path de coordenadas Figma locales → pantalla:
    // escala (sx, sy) y luego traslada (bx, by).
    // Formato Float64List: matriz 4×4 column-major.
    final transformedPath = _wavePath.transform(Float64List.fromList([
      sx,  0,  0, 0,  // columna 0
      0,  sy,  0, 0,  // columna 1
      0,   0,  1, 0,  // columna 2
      bx, by,  0, 1,  // columna 3 (traslación)
    ]));

    // Gradiente horizontal en coordenadas de PANTALLA.
    // Al desplazarse bx entre páginas se revela una porción diferente
    // del gradiente → efecto de cambio de color sutil.
    final gradRect = Rect.fromLTWH(bx, 0, _kPathW * _kGradientFraction * sx, 1);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: _kStripeColors,
        stops: _kStripeStops,
      ).createShader(gradRect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(transformedPath, paint);
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.pageValue != pageValue;

  // ── Path exacto del Figma (strokeGeometry del Vector 2, coordenadas locales) ──
  static Path _buildWavePath() => Path()
    ..moveTo(-90.3099, 95.9800)
    ..cubicTo(-147.2060, 145.8570, -152.8970, 232.4140, -103.0200, 289.3100)
    ..cubicTo(-53.1432, 346.2060, 33.4135, 351.8970, 90.3099, 302.0200)
    ..lineTo(0.0000, 199.0000)
    ..lineTo(-90.3099, 95.9800)
    ..moveTo(1486.5500, 293.7190)
    ..cubicTo(1546.9800, 339.2530, 1632.8800, 327.1800, 1678.4100, 266.7530)
    ..cubicTo(1723.9500, 206.3250, 1711.8800, 120.4260, 1651.4500, 74.8911)
    ..lineTo(1569.0000, 184.3050)
    ..lineTo(1486.5500, 293.7190)
    ..moveTo(0.0000, 199.0000)
    ..cubicTo(90.3099, 302.0200, 90.2939, 302.0340, 90.2787, 302.0470)
    ..cubicTo(90.2748, 302.0510, 90.2604, 302.0630, 90.2525, 302.0700)
    ..cubicTo(90.2368, 302.0840, 90.2243, 302.0950, 90.2152, 302.1030)
    ..cubicTo(90.1970, 302.1190, 90.1920, 302.1230, 90.2002, 302.1160)
    ..cubicTo(90.2167, 302.1020, 90.2856, 302.0420, 90.4060, 301.9370)
    ..cubicTo(90.6468, 301.7280, 91.0928, 301.3430, 91.7350, 300.7920)
    ..cubicTo(93.0202, 299.6900, 95.0863, 297.9320, 97.8619, 295.6110)
    ..cubicTo(103.4210, 290.9620, 111.7770, 284.0980, 122.3590, 275.7600)
    ..cubicTo(143.6710, 258.9690, 173.2780, 236.7880, 206.7430, 214.8640)
    ..cubicTo(240.5850, 192.6920, 275.9550, 172.3810, 308.9830, 158.0070)
    ..cubicTo(343.7380, 142.8800, 366.4240, 138.5350, 377.5520, 138.5350)
    ..lineTo(377.5520, 1.5350)
    ..lineTo(377.5520, -135.4650)
    ..cubicTo(312.5310, -135.4650, 249.9490, -115.1270, 199.6360, -93.2290)
    ..cubicTo(147.5950, -70.5788, 98.0955, -41.5231, 56.5871, -14.3288)
    ..cubicTo(14.7009, 13.1130, -21.5250, 40.2981, -47.2076, 60.5321)
    ..cubicTo(-60.1223, 70.7070, -70.5547, 79.2693, -77.9090, 85.4193)
    ..cubicTo(-81.5903, 88.4977, -84.5123, 90.9817, -86.6012, 92.7725)
    ..cubicTo(-87.6460, 93.6682, -88.4834, 94.3914, -89.1043, 94.9299)
    ..cubicTo(-89.4148, 95.1991, -89.6713, 95.4223, -89.8726, 95.5978)
    ..cubicTo(-89.9732, 95.6855, -90.0601, 95.7614, -90.1330, 95.8251)
    ..cubicTo(-90.1695, 95.8570, -90.2025, 95.8859, -90.2319, 95.9117)
    ..cubicTo(-90.2467, 95.9246, -90.2662, 95.9417, -90.2736, 95.9481)
    ..cubicTo(-90.2922, 95.9644, -90.3099, 95.9800, 0.0000, 199.0000)
    ..moveTo(377.5520, 1.5350)
    ..lineTo(377.5520, 138.5350)
    ..cubicTo(418.1130, 138.5350, 469.9340, 158.8620, 552.0250, 196.9020)
    ..cubicTo(587.9040, 213.5280, 631.1530, 233.9960, 673.1260, 249.2490)
    ..cubicTo(714.6470, 264.3380, 767.4980, 279.2530, 824.0150, 277.1230)
    ..lineTo(818.8550, 140.2200)
    ..lineTo(813.6950, 3.3171)
    ..cubicTo(809.2940, 3.4830, 795.5600, 2.2105, 766.7110, -8.2736)
    ..cubicTo(738.3130, -18.5934, 707.4060, -33.0842, 667.2260, -51.7031)
    ..cubicTo(597.1990, -84.1533, 489.2860, -135.4650, 377.5520, -135.4650)
    ..lineTo(377.5520, 1.5350)
    ..moveTo(818.8550, 140.2200)
    ..lineTo(824.0150, 277.1230)
    ..cubicTo(881.7510, 274.9470, 931.4260, 255.6110, 969.2980, 237.0490)
    ..cubicTo(1005.5000, 219.3070, 1043.5600, 195.4800, 1069.3400, 180.2770)
    ..cubicTo(1131.7200, 143.4910, 1160.4500, 134.5380, 1184.6500, 137.5120)
    ..lineTo(1201.3700, 1.5350)
    ..lineTo(1218.0800, -134.4420)
    ..cubicTo(1092.8100, -149.8370, 991.2110, -91.7436, 930.1610, -55.7425)
    ..cubicTo(894.2280, -34.5530, 872.3010, -20.5512, 848.7100, -8.9889)
    ..cubicTo(826.7920, 1.7533, 816.8780, 3.1971, 813.6950, 3.3171)
    ..lineTo(818.8550, 140.2200)
    ..moveTo(1201.3700, 1.5350)
    ..lineTo(1184.6500, 137.5120)
    ..cubicTo(1228.5500, 142.9070, 1298.9800, 174.7540, 1371.3800, 217.6660)
    ..cubicTo(1404.6600, 237.3860, 1433.9200, 256.7260, 1454.8500, 271.1500)
    ..cubicTo(1465.2700, 278.3260, 1473.5000, 284.1950, 1478.9800, 288.1680)
    ..cubicTo(1481.7200, 290.1530, 1483.7700, 291.6580, 1485.0600, 292.6090)
    ..cubicTo(1485.7000, 293.0850, 1486.1500, 293.4210, 1486.4100, 293.6090)
    ..cubicTo(1486.5300, 293.7030, 1486.6100, 293.7600, 1486.6300, 293.7790)
    ..cubicTo(1486.6400, 293.7880, 1486.6400, 293.7880, 1486.6300, 293.7780)
    ..cubicTo(1486.6200, 293.7730, 1486.6100, 293.7660, 1486.6000, 293.7560)
    ..cubicTo(1486.6000, 293.7510, 1486.5800, 293.7420, 1486.5800, 293.7390)
    ..cubicTo(1486.5700, 293.7290, 1486.5500, 293.7190, 1569.0000, 184.3050)
    ..cubicTo(1651.4500, 74.8911, 1651.4300, 74.8793, 1651.4200, 74.8670)
    ..cubicTo(1651.4100, 74.8620, 1651.3900, 74.8490, 1651.3800, 74.8391)
    ..cubicTo(1651.3500, 74.8192, 1651.3200, 74.7968, 1651.2900, 74.7719)
    ..cubicTo(1651.2200, 74.7221, 1651.1400, 74.6622, 1651.0500, 74.5925)
    ..cubicTo(1650.8600, 74.4529, 1650.6200, 74.2738, 1650.3300, 74.0563)
    ..cubicTo(1649.7500, 73.6213, 1648.9600, 73.0324, 1647.9700, 72.2993)
    ..cubicTo(1645.9900, 70.8335, 1643.2000, 68.7886, 1639.6800, 66.2419)
    ..cubicTo(1632.6600, 61.1529, 1622.6700, 54.0345, 1610.3000, 45.5110)
    ..cubicTo(1585.6600, 28.5354, 1551.0300, 5.6266, 1511.0800, -18.0493)
    ..cubicTo(1437.0300, -61.9300, 1323.6400, -121.4680, 1218.0800, -134.4420)
    ..lineTo(1201.3700, 1.5350);
}

// ─── Pantalla individual ──────────────────────────────────────────────────────

class _OnboardingScreen extends StatelessWidget {
  final _PageData data;
  final double imageHeight;
  const _OnboardingScreen({required this.data, required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ilustración (ocupa la mitad superior, y≈130 en Figma)
          SizedBox(
            height: imageHeight,
            child: Center(
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 100,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
          // Título (y≈495 en Figma = 58.6% desde arriba)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.s32,
            ),
            child: Text(
              data.title,
              style: const TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 34,
                fontWeight: DesignTokens.wExtraBold,
                color: Colors.white,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.s16),
          // Cuerpo (y≈596 en Figma = 70.6% desde arriba)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.s32,
            ),
            child: Text(
              data.body,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 16,
                fontWeight: DesignTokens.wRegular,
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Navegación inferior ──────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final double page;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _BottomNav({
    required this.page,
    required this.total,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final current = page.round();
    final isLast = current == total - 1;
    final label = _kPages[current.clamp(0, _kPages.length - 1)].buttonLabel;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.s32,
          DesignTokens.s8,
          DesignTokens.s32,
          DesignTokens.s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dots (Frame 4 en Figma: 3 líneas/círculos, y≈702)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                total,
                (i) => _Dot(page: page, index: i),
              ),
            ),
            const SizedBox(height: DesignTokens.s24),
            // Fila de botones
            Row(
              children: [
                // OMITIR (izquierda) — siempre visible
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 42),
                  ),
                  child: Text(
                    'OMITIR',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 13,
                      fontWeight: DesignTokens.wMedium,
                      letterSpacing: 0.8,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                const Spacer(),
                // SIGUIENTE / VAMOS (derecha)
                FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _kBg,
                    minimumSize: const Size(113, 42),
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.s24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.rFull),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontWeight: DesignTokens.wSemibold,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: DesignTokens.s6),
                        const Icon(Icons.arrow_forward_rounded, size: 15),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Indicador de página (dots) ───────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final double page;
  final int index;
  const _Dot({required this.page, required this.index});

  @override
  Widget build(BuildContext context) {
    // Animación continua: el dot activo se expande a 24px, los inactivos son 8px
    final dist = (page - index).abs().clamp(0.0, 1.0);
    final width = lerpDouble(24.0, 8.0, dist)!;
    final opacity = lerpDouble(1.0, 0.28, dist)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(DesignTokens.rFull),
      ),
    );
  }
}
