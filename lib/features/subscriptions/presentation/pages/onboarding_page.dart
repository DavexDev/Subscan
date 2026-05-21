import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
        pageBuilder: (ctx, anim, secAnim) => const LoginPage(),
        transitionsBuilder: (ctx, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: DesignTokens.animNormal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080818),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _buildPage('assets/images/onboarding_1.png'),
              _buildPage('assets/images/onboarding_2.png'),
              _buildPage('assets/images/onboarding_3.png'),
            ],
          ),

          // Back button invisible area (top left)
          if (_currentPage > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              width: 60,
              height: 60,
              child: GestureDetector(
                onTap: _goBack,
                behavior: HitTestBehavior.opaque,
              ),
            ),

          // Bottom buttons invisible areas
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            height: 80,
            child: Row(
              children: [
                // OMITIR tap area
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _goToLogin,
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                // SIGUIENTE/VAMOS tap area
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _goToNext,
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(String assetPath) {
    return SizedBox.expand(
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
    );
  }
}
