import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lays out a [display] above a block of [keys] (phone layout).
///
/// The keys keep their natural height when there is room for them. When
/// there is not (small phones), the whole block is scaled down uniformly so
/// that the display always keeps at least [minDisplayHeight].
class KeysFitLayout extends StatelessWidget {
  const KeysFitLayout({
    super.key,
    required this.display,
    required this.keys,
    this.minDisplayHeight = 124,
  });

  final Widget display;
  final Widget keys;

  /// Height (at text scale 1.0) the display needs to avoid overflowing:
  /// vertical padding + expression line + result line + separator.
  final double minDisplayHeight;

  @override
  Widget build(BuildContext context) {
    // Larger system fonts make the display taller, so its minimum grows too.
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    final double minDisplay =
        minDisplayHeight * (textScale < 1 ? 1.0 : textScale);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double keysMaxHeight =
            math.max(0.0, constraints.maxHeight - minDisplay);

        return Column(
          children: [
            Expanded(child: display),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: keysMaxHeight),
              // scaleDown never enlarges: with enough room the scale is 1.0
              // and the layout is identical to the unscaled one.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: constraints.maxWidth, child: keys),
              ),
            ),
          ],
        );
      },
    );
  }
}
