import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Copies picked photos into the app's own documents directory so they
/// survive independently of wherever the user originally took/found them
/// (the OS is free to clear the image_picker cache at any time).
class ImageStorageService {
  static final Uuid _uuid = Uuid();

  Future<String> persistImage(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final closetDir = Directory(p.join(appDir.path, 'closet_photos'));
    if (!await closetDir.exists()) {
      await closetDir.create(recursive: true);
    }

    final extension = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final fileName = '${_uuid.v4()}$extension';
    final destinationPath = p.join(closetDir.path, fileName);

    await File(sourcePath).copy(destinationPath);
    return destinationPath;
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
