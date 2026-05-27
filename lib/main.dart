import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:subscan/core/services/notification_service.dart';
import 'package:subscan/core/theme/app_theme.dart';
import 'package:subscan/features/onboarding/presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las credenciales privadas desde .env (ver .env.example).
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw Exception(
      'Faltan SUPABASE_URL / SUPABASE_ANON_KEY en .env. '
      'Copia .env.example a .env y rellena los valores reales.',
    );
  }

  await Firebase.initializeApp();
  await NotificationService.init();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: PodaApp()));
}

class PodaApp extends StatelessWidget {
  const PodaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PODA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingPage(),
    );
  }
}
