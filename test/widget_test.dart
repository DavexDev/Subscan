import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscan/main.dart';
import 'package:subscan/features/subscriptions/presentation/pages/splash_page.dart';

void main() {
  testWidgets('SubScan app arranca correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SubScanApp()),
    );
    // Verifica que la pantalla de login está visible
    expect(find.text('SubScan'), findsAtLeastNWidgets(1));
  });
}
