import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;

  final List<String> _images = [
    'assets/images/onboarding_1.png',
    'assets/images/onboarding_2.png',
    'assets/images/onboarding_3.png',
  ];

  void _goToNext() {
    if (_currentPage < 2) {
      setState(() {
        _currentPage++;
      });
    } else {
      _goToLogin();
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
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
          // Background images with cross-fade transition
          SizedBox.expand(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.asset(
                _images[_currentPage],
                key: ValueKey<int>(_currentPage),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Invisible touch areas for swiping
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < -300) {
                  _goToNext(); // Swipe left
                } else if (details.primaryVelocity! > 300) {
                  _goBack(); // Swipe right
                }
              },
            ),
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
}
