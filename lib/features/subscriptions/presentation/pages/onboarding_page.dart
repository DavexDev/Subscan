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

  final List<Map<String, String>> _pages = [
    {
      'title': 'Demasiadas\nsuscripciones',
      'subtitle': 'Controla todos tus pagos y evita gastos\ninnecesarios cada mes.',
      'image': 'assets/images/onboarding_ill_1.png',
    },
    {
      'title': 'Analizamos\ntus gastos',
      'subtitle': 'PODA detecta renovaciones\nautomáticas y servicios que casi no utilizas.',
      'image': 'assets/images/onboarding_ill_2.png',
    },
    {
      'title': 'Poda*\nlo innecesario',
      'subtitle': 'Ahorra dinero cancelando suscripciones que ya no aportan valor.',
      'image': 'assets/images/onboarding_ill_3.png',
    },
  ];

  void _goToNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
          // Background Gradient and Teal Blob
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4A0).withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4A0).withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top area: Back button (if applicable) and Illustration
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      // Illustration
                      Positioned.fill(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (idx) => setState(() => _currentPage = idx),
                          itemCount: _pages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                              child: Image.asset(
                                _pages[index]['image']!,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Back button (visible on page 2 and 3)
                      if (_currentPage > 0)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                            onPressed: _goBack,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Bottom area: Texts and Buttons
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        // Title
                        Text(
                          _pages[_currentPage]['title']!,
                          style: const TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        Text(
                          _pages[_currentPage]['subtitle']!,
                          style: TextStyle(
                            fontFamily: DesignTokens.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF909090),
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),
                        
                        // Dots Indicator
                        Row(
                          children: List.generate(
                            _pages.length,
                            (index) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: _currentPage == index ? 32 : 12,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _goToLogin,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontFamily: DesignTokens.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('OMITIR'),
                            ),
                            ElevatedButton(
                              onPressed: _goToNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9243FF), // Figma purple
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: DesignTokens.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Text(_currentPage == 2 ? 'VAMOS' : 'SIGUIENTE'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
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
