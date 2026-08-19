import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dap_flash_tool/app.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DapFlashApp()),
    );

    // Verify the app renders (home page should be visible)
    expect(find.byType(DapFlashApp), findsOneWidget);
  });
}
