import 'package:flutter_riverpod/flutter_riverpod.dart';

/// null = tutorial inactivo, 0..N = paso activo
final tutorialStepProvider = StateProvider<int?>((ref) => null);

/// Pestaña activa del MainShell (0=Inicio, 1=Stats, 2=Poda, 3=Alertas, 4=Cuenta)
final selectedTabProvider = StateProvider<int>((ref) => 0);
