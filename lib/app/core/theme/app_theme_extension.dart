import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_decoration.dart';

extension AppThemeContext on BuildContext {
  // Cores
  Color get primaryColor => AppColors.primary;
  Color get primaryDark => AppColors.primaryDark;
  Color get primaryLight => AppColors.primaryLight;
  Color get primarySurface => AppColors.primarySurface;
  Color get backgroundColor => AppColors.background;
  Color get surfaceColor => AppColors.surface;
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textHint => AppColors.textHint;
  Color get errorColor => AppColors.error;
  Color get successColor => AppColors.success;
  Color get ratingColor => AppColors.rating;
  Color get borderColor => AppColors.border;
  Color get dividerColor => AppColors.divider;
  
  // Text Styles
  TextStyle get titleLarge => AppTextStyles.titleLarge;
  TextStyle get titleMedium => AppTextStyles.titleMedium;
  TextStyle get titleSmall => AppTextStyles.titleSmall;
  TextStyle get bodyLarge => AppTextStyles.bodyLarge;
  TextStyle get bodyMedium => AppTextStyles.bodyMedium;
  TextStyle get bodySmall => AppTextStyles.bodySmall;
  TextStyle get label => AppTextStyles.label;
  TextStyle get caption => AppTextStyles.caption;
  TextStyle get buttonStyle => AppTextStyles.button;
  TextStyle get price => AppTextStyles.price;
  
  // Border Radius
  BorderRadius get borderRadiusSmall => AppDecoration.borderRadiusSmall;
  BorderRadius get borderRadiusMedium => AppDecoration.borderRadiusMedium;
  BorderRadius get borderRadiusLarge => AppDecoration.borderRadiusLarge;
  
  // Decorations
  BoxDecoration get cardDecoration => AppDecoration.cardDecoration;
  BoxDecoration get searchDecoration => AppDecoration.searchDecoration;
  BoxDecoration chipDecoration({required bool selected}) => 
      AppDecoration.chipDecoration(selected: selected);
}
