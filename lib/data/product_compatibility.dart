import 'package:flutter/painting.dart';
import 'package:smoothapp_poc/pages/food_preferences/food_preferences.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';

class ProductCompatibility {
  final double? level;
  final ProductCompatibilityType type;

  factory ProductCompatibility(double? level) {
    if (foodPreferencesDefined) {
      return ProductCompatibility._(level);
    } else {
      return const ProductCompatibility.unset();
    }
  }

  ProductCompatibility._(this.level)
      : type = switch (level) {
          null => ProductCompatibilityType.unknown,
          >= 66 => ProductCompatibilityType.high,
          >= 33 && < 66 => ProductCompatibilityType.medium,
          _ => ProductCompatibilityType.low,
        };

  const ProductCompatibility.unset()
      : level = null,
        type = ProductCompatibilityType.unset;

  Color get color => switch (type) {
        ProductCompatibilityType.high => AppColors.compatibilityHigh,
        ProductCompatibilityType.medium => AppColors.compatibilityMedium,
        ProductCompatibilityType.low => AppColors.compatibilityLow,
        ProductCompatibilityType.unset => AppColors.compatibilityUnknown,
        ProductCompatibilityType.unknown => AppColors.compatibilityUnknown,
      };

  Color? get colorWithValue => switch (type) {
        ProductCompatibilityType.high => AppColors.compatibilityHigh,
        ProductCompatibilityType.medium => AppColors.compatibilityMedium,
        ProductCompatibilityType.low => AppColors.compatibilityLow,
        _ => null,
      };
}

enum ProductCompatibilityType {
  unset,
  unknown,
  high,
  medium,
  low;
}
