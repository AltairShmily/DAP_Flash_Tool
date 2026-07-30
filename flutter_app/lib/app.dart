import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';

class DapFlashApp extends ConsumerWidget {
  const DapFlashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'DAP Flash Tool',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
