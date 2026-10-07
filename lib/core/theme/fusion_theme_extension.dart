import 'package:flutter/material.dart';

@immutable
class FusionThemeExtension extends ThemeExtension<FusionThemeExtension> {
  final Color stateActive;
  final Color stateOnActive;
  final Color stateActiveTint;

  final Color passwordLetter;
  final Color passwordDigit;
  final Color passwordSymbol;

  final Color success;
  final Color danger;

  final Color border;
  final Color surfaceVariant;
  final Color track;

  const FusionThemeExtension({
    required this.stateActive,
    required this.stateOnActive,
    required this.stateActiveTint,
    required this.passwordLetter,
    required this.passwordDigit,
    required this.passwordSymbol,
    required this.success,
    required this.danger,
    required this.border,
    required this.surfaceVariant,
    required this.track,
  });

  @override
  FusionThemeExtension copyWith({
    Color? stateActive,
    Color? stateOnActive,
    Color? stateActiveTint,
    Color? passwordLetter,
    Color? passwordDigit,
    Color? passwordSymbol,
    Color? success,
    Color? danger,
    Color? border,
    Color? surfaceVariant,
    Color? track,
  }) {
    return FusionThemeExtension(
      stateActive: stateActive ?? this.stateActive,
      stateOnActive: stateOnActive ?? this.stateOnActive,
      stateActiveTint: stateActiveTint ?? this.stateActiveTint,
      passwordLetter: passwordLetter ?? this.passwordLetter,
      passwordDigit: passwordDigit ?? this.passwordDigit,
      passwordSymbol: passwordSymbol ?? this.passwordSymbol,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      border: border ?? this.border,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      track: track ?? this.track,
    );
  }

  @override
  ThemeExtension<FusionThemeExtension> lerp(
    covariant ThemeExtension<FusionThemeExtension>? other,
    double t,
  ) {
    if (other is! FusionThemeExtension) {
      return this;
    }

    return FusionThemeExtension(
      stateActive: Color.lerp(stateActive, other.stateActive, t)!,
      stateOnActive: Color.lerp(stateOnActive, other.stateOnActive, t)!,
      stateActiveTint: Color.lerp(stateActiveTint, other.stateActiveTint, t)!,
      passwordLetter: Color.lerp(passwordLetter, other.passwordLetter, t)!,
      passwordDigit: Color.lerp(passwordDigit, other.passwordDigit, t)!,
      passwordSymbol: Color.lerp(passwordSymbol, other.passwordSymbol, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      border: Color.lerp(border, other.border, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      track: Color.lerp(track, other.track, t)!,
    );
  }
}
