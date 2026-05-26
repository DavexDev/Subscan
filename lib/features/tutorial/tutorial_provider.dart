import 'package:flutter_riverpod/flutter_riverpod.dart';

/// null = tutorial inactivo, 0..N = paso activo
final tutorialStepProvider = StateProvider<int?>((ref) => null);
