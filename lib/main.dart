import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/fusion_theme.dart';
import 'core/theme/fusion_tokens.dart';
import 'core/theme/token_loader.dart';
import 'features/calculator_app/presentation/pages/calculator_page.dart';
import 'features/calculator_app/presentation/state/calculator_controller.dart';

const String _themeModePreferenceKey = 'theme_mode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final FusionTokens tokens = await TokenLoader.load();
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  final String? savedThemeMode = preferences.getString(_themeModePreferenceKey);
  final ThemeMode initialThemeMode = switch (savedThemeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  runApp(
    App(
      tokens: tokens,
      preferences: preferences,
      initialThemeMode: initialThemeMode,
    ),
  );
}

class App extends StatefulWidget {
  const App({
    super.key,
    required this.tokens,
    required this.preferences,
    required this.initialThemeMode,
  });

  final FusionTokens tokens;
  final SharedPreferences preferences;
  final ThemeMode initialThemeMode;

  static State<App>? of(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late ThemeMode _themeMode;
  late final CalculatorController _calculatorController;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _calculatorController = CalculatorController(widget.preferences);
  }

  void _toggleTheme() {
    final Brightness platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final bool isDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);
    final ThemeMode nextMode = isDark ? ThemeMode.light : ThemeMode.dark;

    setState(() {
      _themeMode = nextMode;
    });

    unawaited(_saveThemeMode(nextMode));
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final bool saved = await widget.preferences.setString(
      _themeModePreferenceKey,
      mode.name,
    );

    if (!saved) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError('Could not save the selected theme mode.'),
          library: 'calc app',
        ),
      );
    }
  }

  @override
  void dispose() {
    _calculatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final bool isDark = _themeMode == ThemeMode.dark ||
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
      title: 'Calc App',
      debugShowCheckedModeBanner: false,
      theme: FusionTheme.light(widget.tokens),
      darkTheme: FusionTheme.dark(widget.tokens),
      themeMode: _themeMode,
      home: CalculatorPage(
        controller: _calculatorController,
        onThemeToggle: _toggleTheme,
        isDarkMode: isDark,
      ),
    );
  }
}
