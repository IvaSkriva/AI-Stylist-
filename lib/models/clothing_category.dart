import 'package:flutter/material.dart';

/// The slot a piece of clothing fills when an outfit is assembled.
enum ClothingCategory {
  top,
  bottom,
  dress,
  outerwear,
  shoes,
  accessory,
}

extension ClothingCategoryX on ClothingCategory {
  String get label {
    switch (this) {
      case ClothingCategory.top:
        return 'Top';
      case ClothingCategory.bottom:
        return 'Bottom';
      case ClothingCategory.dress:
        return 'Dress';
      case ClothingCategory.outerwear:
        return 'Outerwear';
      case ClothingCategory.shoes:
        return 'Shoes';
      case ClothingCategory.accessory:
        return 'Accessory';
    }
  }

  IconData get icon {
    switch (this) {
      case ClothingCategory.top:
        return Icons.checkroom;
      case ClothingCategory.bottom:
        return Icons.dry_cleaning;
      case ClothingCategory.dress:
        return Icons.woman;
      case ClothingCategory.outerwear:
        return Icons.ac_unit;
      case ClothingCategory.shoes:
        return Icons.hiking;
      case ClothingCategory.accessory:
        return Icons.watch;
    }
  }

  static ClothingCategory fromName(String name) {
    return ClothingCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => ClothingCategory.top,
    );
  }
}

/// A curated set of colors used for the outfit-matching heuristic.
/// Keeping this as a fixed palette (rather than free text) is what lets
/// [OutfitMatcher] reason about which colors pair well together.
enum ClothingColor {
  black,
  white,
  gray,
  beige,
  navy,
  denim,
  brown,
  red,
  pink,
  orange,
  yellow,
  green,
  blue,
  purple,
}

extension ClothingColorX on ClothingColor {
  String get label {
    final name = this.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Neutral colors are treated as compatible with everything.
  bool get isNeutral {
    switch (this) {
      case ClothingColor.black:
      case ClothingColor.white:
      case ClothingColor.gray:
      case ClothingColor.beige:
      case ClothingColor.navy:
      case ClothingColor.denim:
      case ClothingColor.brown:
        return true;
      default:
        return false;
    }
  }

  Color get swatch {
    switch (this) {
      case ClothingColor.black:
        return const Color(0xFF1A1A1A);
      case ClothingColor.white:
        return const Color(0xFFF5F5F5);
      case ClothingColor.gray:
        return const Color(0xFF9E9E9E);
      case ClothingColor.beige:
        return const Color(0xFFE8DCC4);
      case ClothingColor.navy:
        return const Color(0xFF1B2A4A);
      case ClothingColor.denim:
        return const Color(0xFF4A6FA5);
      case ClothingColor.brown:
        return const Color(0xFF6B4226);
      case ClothingColor.red:
        return const Color(0xFFD1495B);
      case ClothingColor.pink:
        return const Color(0xFFE8A0BF);
      case ClothingColor.orange:
        return const Color(0xFFE07A3F);
      case ClothingColor.yellow:
        return const Color(0xFFE8C547);
      case ClothingColor.green:
        return const Color(0xFF6B8F71);
      case ClothingColor.blue:
        return const Color(0xFF4A7BA6);
      case ClothingColor.purple:
        return const Color(0xFF8A6FA6);
    }
  }

  static ClothingColor fromName(String name) {
    return ClothingColor.values.firstWhere(
      (color) => color.name == name,
      orElse: () => ClothingColor.black,
    );
  }
}
