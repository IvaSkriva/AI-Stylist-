import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/clothing_category.dart';
import '../models/clothing_item.dart';
import '../services/database_helper.dart';
import '../services/image_storage_service.dart';

/// Holds the in-memory copy of the closet and keeps it in sync with the
/// on-device database. The UI only ever talks to this provider - it never
/// touches [DatabaseHelper] directly.
class ClosetProvider extends ChangeNotifier {
  ClosetProvider({
    DatabaseHelper? databaseHelper,
    ImageStorageService? imageStorageService,
  })  : _db = databaseHelper ?? DatabaseHelper.instance,
        _imageStorage = imageStorageService ?? ImageStorageService();

  final DatabaseHelper _db;
  final ImageStorageService _imageStorage;
  static final Uuid _uuid = Uuid();

  List<ClothingItem> _items = <ClothingItem>[];
  bool _isLoading = true;

  List<ClothingItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  List<ClothingItem> itemsInCategory(ClothingCategory category) {
    return _items.where((item) => item.category == category).toList();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    _items = await _db.getAllItems();

    _isLoading = false;
    notifyListeners();
  }

  /// Copies [pickedImagePath] into permanent app storage, then saves the
  /// new closet item to the database.
  Future<void> addItem({
    required String pickedImagePath,
    required ClothingCategory category,
    required ClothingColor color,
    required String name,
  }) async {
    final persistedPath = await _imageStorage.persistImage(pickedImagePath);

    final item = ClothingItem(
      id: _uuid.v4(),
      imagePath: persistedPath,
      category: category,
      color: color,
      name: name.trim().isEmpty ? category.label : name.trim(),
      createdAt: DateTime.now(),
    );

    await _db.insertItem(item);
    _items = <ClothingItem>[item, ..._items];
    notifyListeners();
  }

  Future<void> removeItem(ClothingItem item) async {
    await _db.deleteItem(item.id);
    await _imageStorage.deleteImage(item.imagePath);
    _items = _items.where((existing) => existing.id != item.id).toList();
    notifyListeners();
  }
}
