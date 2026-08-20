import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dap_flash_tool/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register a fake handler for bitsdojo_window's method channel
  // so the native plugin doesn't throw MissingPluginException in tests.
  const channel = MethodChannel('bitsdojo_window');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    switch (call.method) {
      case 'getScreenSize':
        return {'width': 1920.0, 'height': 1080.0};
      case 'getMinWindowSize':
        return {'width': 900.0, 'height': 600.0};
      case 'getMaxWindowSize':
        return {'width': 1920.0, 'height': 1080.0};
      case 'isMaximized':
        return false;
      case 'isVisible':
        return true;
      default:
        return null;
    }
  });

  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DapFlashApp()),
    );

    // Verify the app renders (home page should be visible)
    expect(find.byType(DapFlashApp), findsOneWidget);
  });
}
