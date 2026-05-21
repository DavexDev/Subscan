import 'package:flutter/material.dart';
import 'package:subscan/core/theme/design_tokens.dart';
import 'package:subscan/features/subscriptions/presentation/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
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
    // Calculate approximate positions based on screen size
    final fieldHeight = 56.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFF080818),
      resizeToAvoidBottomInset: true,
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
          
          // Real functional fields overlaid precisely
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine vertical offsets based on image proportions
                // Email field is roughly at 47% from the top
                final emailTop = constraints.maxHeight * 0.445;
                // Password field is roughly at 56%
                final passwordTop = constraints.maxHeight * 0.542;
                
                return Stack(
                  children: [
                    // Email Field
                    Positioned(
                      top: emailTop,
                      left: 30,
                      right: 30,
                      height: fieldHeight,
                      child: _DarkTextField(
                        controller: _emailController,
                        hint: 'Email...',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    
                    // Password Field
                    Positioned(
                      top: passwordTop,
                      left: 30,
                      right: 30,
                      height: fieldHeight,
                      child: _DarkTextField(
                        controller: _passwordController,
                        hint: 'Contraseña...',
                        obscureText: _obscurePassword,
                        isPassword: true,
                        onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
          
          // Invisible hit box for Iniciar Sesión button
          Positioned(
            bottom: size.height * 0.28,
            left: 30,
            right: 30,
            height: 60,
            child: GestureDetector(
              onTap: _handleSignIn,
              behavior: HitTestBehavior.opaque,
            ),
          ),

          // Invisible hit box for Google button
          Positioned(
            bottom: size.height * 0.12,
            left: size.width * 0.25,
            right: size.width * 0.25,
            height: 50,
            child: GestureDetector(
              onTap: _handleSignIn,
              behavior: HitTestBehavior.opaque,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool isPassword;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;

  const _DarkTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.isPassword = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13132A), // Opaque to hide the baked-in placeholder
        borderRadius: BorderRadius.circular(16), // Match Figma radius
        // Use a subtle border if necessary to match the image precisely
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
          // Optional eye icon for password
          suffixIcon: isPassword 
              ? GestureDetector(
                  onTap: onToggleVisibility,
                  child: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 20,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
