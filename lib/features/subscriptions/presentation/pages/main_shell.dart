import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/tutorial/tutorial_provider.dart';
import 'dashboard_page.dart';
import 'estadisticas_page.dart';
import 'poda_page.dart';
import 'alertas_page.dart';
import 'mi_cuenta_page.dart';

const Color _kBg = Color(0xFF030B3F);
const Color _kOverlayCard = Color(0xFF0D1854);

// ─── Tutorial step data ───────────────────────────────────────────────────────

class _TutStep {
  final int tabIndex;
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _TutStep({
    required this.tabIndex,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

const List<_TutStep> _tutSteps = [
  _TutStep(
    tabIndex: 0,
    icon: Icons.home_rounded,
    title: 'Inicio — Tu panel',
    description:
        'Aquí ves todas tus suscripciones de un vistazo. Las tarjetas cambian de color según urgencia: verde (activa), amarillo (vence pronto) y rojo (vencida o urgente). Toca "+" para agregar una nueva.',
    color: Color(0xFF4F6BFF),
  ),
  _TutStep(
    tabIndex: 1,
    icon: Icons.bar_chart_rounded,
    title: 'Estadísticas',
    description:
        'Analiza en qué estás gastando. Encontrarás gráficas por categoría, historial mensual y comparativas para tomar mejores decisiones sobre tus suscripciones.',
    color: Color(0xFF07D47B),
  ),
  _TutStep(
    tabIndex: 2,
    icon: Icons.content_cut_rounded,
    title: 'PODA — Optimiza',
    description:
        'PODA revisa tus suscripciones y te sugiere cuáles cancelar o renegociar. Si tienes servicios duplicados o que poco usas, aquí lo detectarás y podrás actuar.',
    color: Color(0xFFFFB547),
  ),
  _TutStep(
    tabIndex: 3,
    icon: Icons.notifications_rounded,
    title: 'Alertas',
    description:
        'Recibe avisos antes de que venzan tus suscripciones. Configura con cuántos días de anticipación quieres ser notificado para nunca ser sorprendido por un cobro.',
    color: Color(0xFFFF6B6B),
  ),
  _TutStep(
    tabIndex: 4,
    icon: Icons.person_rounded,
    title: 'Mi Cuenta',
    description:
        'Gestiona tu perfil, estadísticas personales y preferencias. Puedes conectar Gmail para detectar suscripciones automáticamente. Este tutorial siempre está disponible aquí.',
    color: Color(0xFFAA80FF),
  ),
];

// ─── Shell ────────────────────────────────────────────────────────────────────

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    DashboardPage(),
    EstadisticasPage(),
    PodaPage(),
    AlertasPage(),
    MiCuentaPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstLaunch());
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('tutorial_seen') ?? false;
    if (!seen && mounted) {
      _activateTutorial(0);
    }
  }

  void _activateTutorial(int step) {
    ref.read(tutorialStepProvider.notifier).state = step;
    setState(() => _currentIndex = _tutSteps[step].tabIndex);
  }

  void _goToStep(int step) {
    ref.read(tutorialStepProvider.notifier).state = step;
    setState(() => _currentIndex = _tutSteps[step].tabIndex);
  }

  Future<void> _endTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen', true);
    ref.read(tutorialStepProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final tutStep = ref.watch(tutorialStepProvider);

    // When tutorial is activated from Mi Cuenta settings
    ref.listen<int?>(tutorialStepProvider, (prev, next) {
      if (next != null && prev == null) {
        setState(() => _currentIndex = _tutSteps[next].tabIndex);
      }
    });

    // Navigation triggered from any child widget (e.g. avatar → cuenta)
    ref.listen<int>(selectedTabProvider, (_, next) {
      if (next != _currentIndex) setState(() => _currentIndex = next);
    });

    return Scaffold(
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: tutStep != null,
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          if (tutStep != null) ...[
            Container(color: Colors.black.withValues(alpha: 0.55)),
            _TutorialCard(
              step: tutStep,
              total: _tutSteps.length,
              tutStep: _tutSteps[tutStep],
              isLast: tutStep == _tutSteps.length - 1,
              onNext: tutStep < _tutSteps.length - 1
                  ? () => _goToStep(tutStep + 1)
                  : null,
              onPrev: tutStep > 0 ? () => _goToStep(tutStep - 1) : null,
              onEnd: _endTutorial,
            ),
          ],
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: tutStep == null
            ? (i) {
                ref.read(selectedTabProvider.notifier).state = i;
                setState(() => _currentIndex = i);
              }
            : (_) {},
      ),
    );
  }
}

// ─── Tutorial card overlay ────────────────────────────────────────────────────

class _TutorialCard extends StatelessWidget {
  final int step;
  final int total;
  final _TutStep tutStep;
  final bool isLast;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
  final VoidCallback onEnd;

  const _TutorialCard({
    required this.step,
    required this.total,
    required this.tutStep,
    required this.isLast,
    required this.onNext,
    required this.onPrev,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: _kOverlayCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          DesignTokens.s20,
          DesignTokens.s16,
          DesignTokens.s20,
          DesignTokens.s20 +
              MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle + skip row
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.s12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paso ${step + 1} de $total',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontFamily,
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: DesignTokens.wMedium,
                  ),
                ),
                if (!isLast)
                  GestureDetector(
                    onTap: onEnd,
                    child: Text(
                      'Saltar',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontFamily,
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: DesignTokens.wMedium,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.s16),
            // Icon + title
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tutStep.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tutStep.color.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(tutStep.icon, color: tutStep.color, size: 24),
                ),
                const SizedBox(width: DesignTokens.s12),
                Expanded(
                  child: Text(
                    tutStep.title,
                    style: const TextStyle(
                      fontFamily: DesignTokens.fontFamily,
                      fontSize: 20,
                      fontWeight: DesignTokens.wBold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.s12),
            // Description
            Text(
              tutStep.description,
              style: TextStyle(
                fontFamily: DesignTokens.fontFamily,
                fontSize: 14,
                height: 1.55,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: DesignTokens.s20),
            // Dots
            Row(
              children: List.generate(total, (i) {
                final active = i == step;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 6),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? tutStep.color
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: DesignTokens.s16),
            // Navigation buttons
            Row(
              children: [
                if (onPrev != null) ...[
                  SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: onPrev,
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Anterior'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 14,
                          fontWeight: DesignTokens.wMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.rL),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.s8),
                ],
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isLast ? onEnd : onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tutStep.color,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DesignTokens.rL),
                        ),
                      ),
                      child: Text(
                        isLast ? '¡Listo, empecemos!' : 'Siguiente',
                        style: const TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 15,
                          fontWeight: DesignTokens.wSemibold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: _kBg,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withValues(alpha: 0.4),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: 11,
        fontWeight: DesignTokens.wSemibold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: 11,
        fontWeight: DesignTokens.wRegular,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.content_cut_rounded),
          label: 'PODA',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_rounded),
          label: 'Alertas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Cuenta',
        ),
      ],
    );
  }
}
