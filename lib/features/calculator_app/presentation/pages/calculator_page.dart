import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/calculator_state.dart';
import '../state/calculator_controller.dart';
import '../widgets/basic_keyboard.dart';
import '../widgets/display_panel.dart';
import '../widgets/scientific_panel.dart';
import '../widgets/top_bar.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({
    super.key,
    required this.controller,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  final CalculatorController controller;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  /// Windows with a shortest side >= this value (dp) use the tablet layout.
  static const double _tabletBreakpoint = 600;

  /// Tablet: vertical split between display and keys.
  static const int _tabletDisplayFlex = 2;
  static const int _tabletKeysFlex = 5;

  /// Tablet: 3 scientific columns next to 4 basic columns keeps key widths equal.
  static const int _scientificFlex = 3;
  static const int _basicFlex = 4;

  /// Approximate width of the DEG/RAD button, used to centre the fx toggle under it.
  static const double _angleButtonWidth = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool isTablet =
        MediaQuery.sizeOf(context).shortestSide >= _tabletBreakpoint;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: ValueListenableBuilder<CalculatorState>(
            valueListenable: widget.controller,
            builder: (context, state, _) =>
                isTablet ? _buildTablet(state) : _buildPhone(state),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(CalculatorState state) {
    return TopBar(
      angleUnit: state.angleUnit,
      onAngleUnitToggle: widget.controller.toggleAngleUnit,
      onThemeToggle: widget.onThemeToggle,
      isDarkMode: widget.isDarkMode,
    );
  }

  Widget _buildDisplay(CalculatorState state) {
    return DisplayPanel(
      expression: state.expression,
      result: state.result,
      errorMessage: state.errorMessage,
    );
  }

  Widget _buildPhone(CalculatorState state) {
    return Column(
      children: [
        _buildTopBar(state),
        Expanded(child: _buildDisplay(state)),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScientificPanel(
                isOpen: state.isScientificOpen,
                onToggle: widget.controller.toggleScientificPanel,
                onToken: widget.controller.appendToken,
                openParenKey: state.openParenKey,
              ),
              const SizedBox(height: 6),
              BasicKeyboard(
                onToken: widget.controller.appendToken,
                onClear: widget.controller.clear,
                onDelete: widget.controller.deleteLastChar,
                onEvaluate: widget.controller.evaluate,
                openParenKey: state.openParenKey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTablet(CalculatorState state) {
    return Column(
      children: [
        _buildTopBar(state),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SizedBox(
              width: _angleButtonWidth,
              child: ScientificToggle(
                isOpen: state.isScientificOpen,
                onToggle: widget.controller.toggleScientificPanel,
              ),
            ),
          ),
        ),
        Expanded(flex: _tabletDisplayFlex, child: _buildDisplay(state)),
        Expanded(
          flex: _tabletKeysFlex,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.isScientificOpen) ...[
                  Expanded(
                    flex: _scientificFlex,
                    child: ScientificKeypad(
                      onToken: widget.controller.appendToken,
                      openParenKey: state.openParenKey,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: _basicFlex,
                  child: BasicKeyboard(
                    expandToFill: true,
                    onToken: widget.controller.appendToken,
                    onClear: widget.controller.clear,
                    onDelete: widget.controller.deleteLastChar,
                    onEvaluate: widget.controller.evaluate,
                    openParenKey: state.openParenKey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
