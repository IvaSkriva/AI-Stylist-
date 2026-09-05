import 'clothing_item.dart';

/// A generated combination of clothing items. Any slot may be empty -
/// e.g. a dress-based outfit has no [top]/[bottom].
class Outfit {
  final ClothingItem? top;
  final ClothingItem? bottom;
  final ClothingItem? dress;
  final ClothingItem? outerwear;
  final ClothingItem? shoes;
  final ClothingItem? accessory;

  const Outfit({
    this.top,
    this.bottom,
    this.dress,
    this.outerwear,
    this.shoes,
    this.accessory,
  });

  /// All non-empty pieces in this outfit, in display order.
  List<ClothingItem> get pieces => <ClothingItem?>[
        dress,
        top,
        bottom,
        outerwear,
        shoes,
        accessory,
      ].whereType<ClothingItem>().toList();
}
