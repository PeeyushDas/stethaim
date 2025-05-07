import 'package:flutter/material.dart';
import 'package:stethaim/utils/size_config.dart';

class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle heading1SemiBold;
  final TextStyle heading1Medium;
  final TextStyle heading2SemiBold;
  final TextStyle heading2Medium;
  final TextStyle heading3SemiBold;
  final TextStyle heading3Medium;
  final TextStyle heading4SemiBold;
  final TextStyle heading4Medium;
  final TextStyle heading5SemiBold;
  final TextStyle heading5Medium;
  final TextStyle body1SemiBold;
  final TextStyle body1Medium;
  final TextStyle body2SemiBold;
  final TextStyle body2Medium;
  final TextStyle body3SemiBold;
  final TextStyle body3Medium;
  final TextStyle body4SemiBold;
  final TextStyle body4Medium;

  const AppTypography({
    required this.heading1SemiBold,
    required this.heading1Medium,
    required this.heading2SemiBold,
    required this.heading2Medium,
    required this.heading3SemiBold,
    required this.heading3Medium,
    required this.heading4SemiBold,
    required this.heading4Medium,
    required this.heading5SemiBold,
    required this.heading5Medium,
    required this.body1SemiBold,
    required this.body1Medium,
    required this.body2SemiBold,
    required this.body2Medium,
    required this.body3SemiBold,
    required this.body3Medium,
    required this.body4SemiBold,
    required this.body4Medium,
  });

  // Methods to get styles with custom colors
  TextStyle heading1SemiBoldWithColor(Color color) =>
      heading1SemiBold.copyWith(color: color);
  TextStyle heading1MediumWithColor(Color color) =>
      heading1Medium.copyWith(color: color);
  TextStyle heading2SemiBoldWithColor(Color color) =>
      heading2SemiBold.copyWith(color: color);
  TextStyle heading2MediumWithColor(Color color) =>
      heading2Medium.copyWith(color: color);
  TextStyle heading3SemiBoldWithColor(Color color) =>
      heading3SemiBold.copyWith(color: color);
  TextStyle heading3MediumWithColor(Color color) =>
      heading3Medium.copyWith(color: color);
  TextStyle heading4SemiBoldWithColor(Color color) =>
      heading4SemiBold.copyWith(color: color);
  TextStyle heading4MediumWithColor(Color color) =>
      heading4Medium.copyWith(color: color);
  TextStyle heading5SemiBoldWithColor(Color color) =>
      heading5SemiBold.copyWith(color: color);
  TextStyle heading5MediumWithColor(Color color) =>
      heading5Medium.copyWith(color: color);
  TextStyle body1SemiBoldWithColor(Color color) =>
      body1SemiBold.copyWith(color: color);
  TextStyle body1MediumWithColor(Color color) =>
      body1Medium.copyWith(color: color);
  TextStyle body2SemiBoldWithColor(Color color) =>
      body2SemiBold.copyWith(color: color);
  TextStyle body2MediumWithColor(Color color) =>
      body2Medium.copyWith(color: color);
  TextStyle body3SemiBoldWithColor(Color color) =>
      body3SemiBold.copyWith(color: color);
  TextStyle body3MediumWithColor(Color color) =>
      body3Medium.copyWith(color: color);
  TextStyle body4SemiBoldWithColor(Color color) =>
      body4SemiBold.copyWith(color: color);
  TextStyle body4MediumWithColor(Color color) =>
      body4Medium.copyWith(color: color);

  static AppTypography of(BuildContext context) {
    SizeConfig.init(context);
    return AppTypography(
      heading1SemiBold: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w600,
        fontSize: 4.8 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (4.8 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      heading1Medium: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w500,
        fontSize: 4.8 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (4.8 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      heading2SemiBold: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w600,
        fontSize: 3.6 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (3.6 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      heading2Medium: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w500,
        fontSize: 3.6 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (3.6 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      heading3SemiBold: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w600,
        fontSize: 3.2 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (3.2 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      heading3Medium: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w500,
        fontSize: 3.2 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (3.2 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      heading4SemiBold: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w600,
        fontSize: 2.4 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (2.4 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      heading4Medium: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w500,
        fontSize: 2.4 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (2.4 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      heading5SemiBold: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w600,
        fontSize: 2.0 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (2.0 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      heading5Medium: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w500,
        fontSize: 2.0 * SizeConfig.textMultiplier,
        height: 1.2,
        letterSpacing: -0.02 * (2.0 * SizeConfig.textMultiplier),
        color: Colors.black,
      ),
      body1SemiBold: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w600,
        fontSize: 1.8 * SizeConfig.textMultiplier,
        height: 1.5,
        letterSpacing: 0,
        color: Colors.black,
      ),
      body1Medium: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w400,
        fontSize: 1.8 * SizeConfig.textMultiplier,
        height: 1.5,
        letterSpacing: 0,
        color: Colors.black,
      ),
      body2SemiBold: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w600,
        fontSize: 1.6 * SizeConfig.textMultiplier,
        height: 1.5,
        letterSpacing: 0,
        color: Colors.black,
      ),
      body2Medium: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w400,
        fontSize: 1.6 * SizeConfig.textMultiplier,
        height: 1.5,
        letterSpacing: 0,
        color: Colors.black,
      ),
      body3SemiBold: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w600,
        fontSize: 1.4 * SizeConfig.textMultiplier,
        height: 1.5,
        letterSpacing: 0,
        color: Colors.black,
      ),
      body3Medium: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w400,
        fontSize: 1.4 * SizeConfig.textMultiplier,
        height: 1.5,
        letterSpacing: 0,
        color: Colors.black,
      ),
      body4SemiBold: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w600,
        fontSize: 1.2 * SizeConfig.textMultiplier,
        height: 1.5,
        letterSpacing: 0,
        color: Colors.black,
      ),
      body4Medium: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w400,
        fontSize: 1.2 * SizeConfig.textMultiplier,
        height: 1.5,
        letterSpacing: 0,
        color: Colors.black,
      ),
    );
  }

  @override
  ThemeExtension<AppTypography> copyWith({
    TextStyle? heading1SemiBold,
    TextStyle? heading1Medium,
    TextStyle? heading2SemiBold,
    TextStyle? heading2Medium,
    TextStyle? heading3SemiBold,
    TextStyle? heading3Medium,
    TextStyle? heading4SemiBold,
    TextStyle? heading4Medium,
    TextStyle? heading5SemiBold,
    TextStyle? heading5Medium,
    TextStyle? body1SemiBold,
    TextStyle? body1Medium,
    TextStyle? body2SemiBold,
    TextStyle? body2Medium,
    TextStyle? body3SemiBold,
    TextStyle? body3Medium,
    TextStyle? body4SemiBold,
    TextStyle? body4Medium,
  }) {
    return AppTypography(
      heading1SemiBold: heading1SemiBold ?? this.heading1SemiBold,
      heading1Medium: heading1Medium ?? this.heading1Medium,
      heading2SemiBold: heading2SemiBold ?? this.heading2SemiBold,
      heading2Medium: heading2Medium ?? this.heading2Medium,
      heading3SemiBold: heading3SemiBold ?? this.heading3SemiBold,
      heading3Medium: heading3Medium ?? this.heading3Medium,
      heading4SemiBold: heading4SemiBold ?? this.heading4SemiBold,
      heading4Medium: heading4Medium ?? this.heading4Medium,
      heading5SemiBold: heading5SemiBold ?? this.heading5SemiBold,
      heading5Medium: heading5Medium ?? this.heading5Medium,
      body1SemiBold: body1SemiBold ?? this.body1SemiBold,
      body1Medium: body1Medium ?? this.body1Medium,
      body2SemiBold: body2SemiBold ?? this.body2SemiBold,
      body2Medium: body2Medium ?? this.body2Medium,
      body3SemiBold: body3SemiBold ?? this.body3SemiBold,
      body3Medium: body3Medium ?? this.body3Medium,
      body4SemiBold: body4SemiBold ?? this.body4SemiBold,
      body4Medium: body4Medium ?? this.body4Medium,
    );
  }

  @override
  ThemeExtension<AppTypography> lerp(
    covariant ThemeExtension<AppTypography>? other,
    double t,
  ) {
    if (other is! AppTypography) {
      return this;
    }

    return AppTypography(
      heading1SemiBold:
          TextStyle.lerp(heading1SemiBold, other.heading1SemiBold, t)!,
      heading1Medium: TextStyle.lerp(heading1Medium, other.heading1Medium, t)!,
      heading2SemiBold:
          TextStyle.lerp(heading2SemiBold, other.heading2SemiBold, t)!,
      heading2Medium: TextStyle.lerp(heading2Medium, other.heading2Medium, t)!,
      heading3SemiBold:
          TextStyle.lerp(heading3SemiBold, other.heading3SemiBold, t)!,
      heading3Medium: TextStyle.lerp(heading3Medium, other.heading3Medium, t)!,
      heading4SemiBold:
          TextStyle.lerp(heading4SemiBold, other.heading4SemiBold, t)!,
      heading4Medium: TextStyle.lerp(heading4Medium, other.heading4Medium, t)!,
      heading5SemiBold:
          TextStyle.lerp(heading5SemiBold, other.heading5SemiBold, t)!,
      heading5Medium: TextStyle.lerp(heading5Medium, other.heading5Medium, t)!,
      body1SemiBold: TextStyle.lerp(body1SemiBold, other.body1SemiBold, t)!,
      body1Medium: TextStyle.lerp(body1Medium, other.body1Medium, t)!,
      body2SemiBold: TextStyle.lerp(body2SemiBold, other.body2SemiBold, t)!,
      body2Medium: TextStyle.lerp(body2Medium, other.body2Medium, t)!,
      body3SemiBold: TextStyle.lerp(body3SemiBold, other.body3SemiBold, t)!,
      body3Medium: TextStyle.lerp(body3Medium, other.body3Medium, t)!,
      body4SemiBold: TextStyle.lerp(body4SemiBold, other.body4SemiBold, t)!,
      body4Medium: TextStyle.lerp(body4Medium, other.body4Medium, t)!,
    );
  }
}
