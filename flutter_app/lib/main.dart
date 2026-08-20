import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: DapFlashApp(),
    ),
  );

  doWhenWindowReady(() {
    const initialSize = Size(1100, 720);
    appWindow.minSize = const Size(900, 600);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'DAP Flash Tool';
    appWindow.show();
  });
}
