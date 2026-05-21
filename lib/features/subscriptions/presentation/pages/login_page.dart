import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/dashboard_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _handleSignIn(BuildContext context) {
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
    return Scaffold(
      backgroundColor: const Color(0xFF080818),
      body: Stack(
        children: [
          // Background exactly as Figma
          SizedBox.expand(
            child: Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          
          // Invisible hit box for Iniciar Sesión button
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.28,
            left: 30,
            right: 30,
            height: 60,
            child: GestureDetector(
              onTap: () => _handleSignIn(context),
              behavior: HitTestBehavior.opaque,
            ),
          ),

          // Invisible hit box for Google button
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.12,
            left: MediaQuery.of(context).size.width * 0.25,
            right: MediaQuery.of(context).size.width * 0.25,
            height: 50,
            child: GestureDetector(
              onTap: () => _handleSignIn(context),
              behavior: HitTestBehavior.opaque,
            ),
          ),
        ],
      ),
    );
  }
}
