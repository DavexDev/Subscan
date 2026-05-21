import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:subscan/features/subscriptions/presentation/pages/onboarding_page.dart';
import 'package:subscan/core/theme/design_tokens.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _controller.play();
        
        _controller.addListener(_checkVideoEnd);
      }).catchError((_) {
        // En caso de error al cargar el video, navega directamente al onboarding
        _navigateToLogin();
      });
  }

  void _checkVideoEnd() {
    if (_controller.value.isInitialized && 
        _controller.value.position >= _controller.value.duration &&
        !_controller.value.isPlaying) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (_navigated) return;
    _navigated = true;
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingPage(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: DesignTokens.animNormal,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkVideoEnd);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isVideoInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const SizedBox(),
      ),
    );
  }
}
