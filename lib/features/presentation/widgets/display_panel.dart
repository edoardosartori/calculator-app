import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/fusion_motion.dart';
import '../../../../core/theme/fusion_theme_extension.dart';
import '../../domain/expression_formatter.dart';

class DisplayPanel extends StatefulWidget {
  const DisplayPanel({
    super.key,
    required this.expression,
    required this.result,
    this.errorMessage,
    required this.isResultConfirmed,
  });

  final String expression;
  final String result;
  final String? errorMessage;

  /// True while the result has been confirmed with '='; the soft cyan
  /// background stays visible until the next input clears the state.
  final bool isResultConfirmed;

  @override
  State<DisplayPanel> createState() => _DisplayPanelState();
}

class _DisplayPanelState extends State<DisplayPanel> {
  void _copyToClipboard(BuildContext context) {
    if (widget.result.isEmpty || widget.result == '0') return;

    Clipboard.setData(ClipboardData(text: widget.result));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fusionTheme = theme.extension<FusionThemeExtension>();
    final isDark = theme.brightness == Brightness.dark;

    final Color textSecondary = theme.colorScheme.onSurfaceVariant;
    final Color cyanColor =
        fusionTheme?.stateActive ?? theme.colorScheme.primary;
    final Color amberColor =
        fusionTheme?.characterSymbol ?? theme.colorScheme.tertiary;
    final Color dangerColor = fusionTheme?.danger ?? theme.colorScheme.error;
    final Color borderColor = fusionTheme?.border ?? theme.colorScheme.outline;
    final Color activeTint = fusionTheme?.stateActiveTint ??
        theme.colorScheme.primary.withValues(alpha: 0.12);

    final TextStyle expressionStyle = TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    );

    final TextStyle resultStyle = TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: 48,
      fontWeight: FontWeight.w500,
      color: cyanColor,
      shadows: isDark
          ? [
              BoxShadow(
                color: cyanColor.withValues(alpha: 0.18),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ]
          : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: SelectableText.rich(
                    ExpressionFormatter.buildTextSpan(
                      expression: widget.expression,
                      defaultStyle: expressionStyle,
                      amberColor: amberColor,
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onLongPress: () => _copyToClipboard(context),
                  child: AnimatedContainer(
                    duration: FusionMotion.normal,
                    curve: FusionMotion.curve,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isResultConfirmed
                          ? activeTint
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Semantics(
                        label:
                            widget.errorMessage ?? 'Result: ${widget.result}',
                        child: Text(
                          widget.errorMessage ?? widget.result,
                          style: widget.errorMessage != null
                              ? resultStyle.copyWith(
                                  fontSize: 24,
                                  color: dangerColor,
                                  shadows: null,
                                )
                              : resultStyle,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          color: borderColor,
        ),
      ],
    );
  }
}
