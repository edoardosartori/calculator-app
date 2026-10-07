import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'core/theme/fusion_tokens.dart';
import 'core/theme/fusion_theme.dart';
import 'core/theme/token_loader.dart';
// import 'features/.../presentation/pages/name_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final tokens = await TokenLoader.load();
  final preferences = await SharedPreferences.getInstance();
  final savedThemeMode = preferences.getString(_themeModePreferenceKey);
  final initialThemeMode = switch (savedThemeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  runApp(
    MyApp(
      tokens: tokens,
      preferences: preferences,
      initialThemeMode: initialThemeMode,
    ),
  );
}

const _themeModePreferenceKey = 'theme_mode';

class MyApp extends StatefulWidget {
  final FusionTokens tokens;
  final SharedPreferences preferences;
  final ThemeMode initialThemeMode;

  const MyApp({
    super.key,
    required this.tokens,
    required this.preferences,
    required this.initialThemeMode,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _toggleTheme() {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);
    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;

    setState(() {
      _themeMode = nextMode;
    });

    unawaited(_saveThemeMode(nextMode));
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final saved = await widget.preferences.setString(
      _themeModePreferenceKey,
      mode.name,
    );

    if (!saved) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError('Could not save the selected theme mode.'),
          library: 'calc_app',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: FusionTheme.light(widget.tokens),
      darkTheme: FusionTheme.dark(widget.tokens),
      themeMode: _themeMode,
      /* home: namePage(
        onToggleTheme: _toggleTheme,
        isDarkMode: isDark,
      ), */
    );
  }
}
