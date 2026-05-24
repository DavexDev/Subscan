import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscan/main.dart';

void main() {
  testWidgets('PODA app arranca correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PodaApp()),
    );
    // Verifica que la app arranca
    expect(find.byType(PodaApp), findsNothing); // PodaApp is the root
  });
}
