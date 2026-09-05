import 'clothing_category.dart';

/// A single piece of clothing in the user's digital closet.
class ClothingItem {
  final String id;
  final String imagePath;
  final ClothingCategory category;
  final ClothingColor color;
  final String name;
  final DateTime createdAt;

  const ClothingItem({
    required this.id,
    required this.imagePath,
    required this.category,
    required this.color,
    required this.name,
    required this.createdAt,
  });

  ClothingItem copyWith({
    String? imagePath,
    ClothingCategory? category,
    ClothingColor? color,
    String? name,
  }) {
    return ClothingItem(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      color: color ?? this.color,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'imagePath': imagePath,
      'category': category.name,
      'color': color.name,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClothingItem.fromMap(Map<String, Object?> map) {
    return ClothingItem(
      id: map['id']! as String,
      imagePath: map['imagePath']! as String,
      category: ClothingCategoryX.fromName(map['category']! as String),
      color: ClothingColorX.fromName(map['color']! as String),
      name: map['name']! as String,
      createdAt: DateTime.parse(map['createdAt']! as String),
    );
  }
}
