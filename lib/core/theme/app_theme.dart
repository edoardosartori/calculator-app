import 'package:flutter/material.dart';

import 'fusion_theme.dart';
import 'fusion_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light(FusionTokens tokens) {
    return FusionTheme.light(tokens);
  }

  static ThemeData dark(FusionTokens tokens) {
    return FusionTheme.dark(tokens);
  }
}
