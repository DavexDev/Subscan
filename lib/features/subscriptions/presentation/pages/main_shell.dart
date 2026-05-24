import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'dashboard_page.dart';
import 'estadisticas_page.dart';
import 'poda_page.dart';
import 'alertas_page.dart';
import 'mi_cuenta_page.dart';

const Color _kBg = Color(0xFF030B3F);

/// Shell principal con navegación inferior de 5 pestañas.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    DashboardPage(),
    EstadisticasPage(),
    PodaPage(),
    AlertasPage(),
    MiCuentaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

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
