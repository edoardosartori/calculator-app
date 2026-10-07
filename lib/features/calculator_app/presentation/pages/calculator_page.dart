import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ValueListenableBuilder<CalculatorState>(
          valueListenable: widget.controller,
          builder: (context, state, _) {
            return Column(
              children: [
                TopBar(
                  angleUnit: state.angleUnit,
                  onAngleUnitToggle: widget.controller.toggleAngleUnit,
                  onThemeToggle: widget.onThemeToggle,
                  isDarkMode: widget.isDarkMode,
                ),
                Expanded(
                  child: DisplayPanel(
                    expression: state.expression,
                    result: state.result,
                    errorMessage: state.errorMessage,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScientificPanel(
                        isOpen: state.isScientificOpen,
                        onToggle: widget.controller.toggleScientificPanel,
                        onToken: widget.controller.appendToken,
                      ),
                      const SizedBox(height: 8),
                      BasicKeyboard(
                        onToken: widget.controller.appendToken,
                        onClear: widget.controller.clear,
                        onDelete: widget.controller.deleteLastChar,
                        onEvaluate: widget.controller.evaluate,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
