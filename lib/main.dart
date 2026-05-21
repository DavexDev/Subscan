import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscan/core/theme/app_theme.dart';
import 'package:subscan/features/subscriptions/presentation/pages/splash_page.dart';

void main() {
  runApp(const ProviderScope(child: SubScanApp()));
}

class SubScanApp extends StatelessWidget {
  const SubScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
