# AI Stylist

Photograph the clothes you own, build a digital closet, and get outfit
combinations put together for you.

This first version is a fully working Flutter MVP:

- **Digital closet** - take a photo (or pick from your gallery) of a clothing
  item, tag its category (top, bottom, dress, outerwear, shoes, accessory)
  and color, and it's saved to your closet on-device.
- **Outfit generator** - a rule-based matching engine picks a coherent
  combination from your closet (a top+bottom or a dress, plus optional
  outerwear/shoes/accessory), scoring candidates by color compatibility.
  Tap "Shuffle" for another combination.
- **Everything stays on your phone.** There's no backend/server yet - photos
  are copied into the app's local storage and item metadata lives in a local
  SQLite database (via `sqflite`).

The color-matching logic in `lib/services/outfit_matcher.dart` is
intentionally a simple, well-documented heuristic rather than a real
computer-vision model, so the app is useful from day one. It's the natural
place to plug in a real AI step later - e.g. a vision model that looks at
each photo and automatically extracts its dominant color and style tags
instead of the user picking them from a list.

## Project structure

```
lib/
  models/       Data classes: ClothingItem, ClothingCategory, ClothingColor, Outfit
  services/     DatabaseHelper (sqflite), ImageStorageService, OutfitMatcher
  providers/    ClosetProvider - the app's single source of truth for the closet
  screens/      HomeScreen (closet grid), AddItemScreen, OutfitScreen
  widgets/      ClothingCard, EmptyState
  theme/        AppTheme
```

## Running it locally

This code was written in a cloud sandbox that doesn't have the Flutter
toolchain available, so it hasn't been run through `flutter analyze` or
`flutter run` yet. To get it running on your machine:

1. Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   installed (`flutter doctor` should be green, or at least have one platform
   - Android or iOS - ready).

2. Clone the repo and generate the missing platform folders. `flutter
   create .` is safe to run inside an existing package: it fills in
   `android/`, `ios/`, etc. without touching the existing `lib/` code or
   `pubspec.yaml`.

   ```bash
   git clone https://github.com/IvaSkriva/AI-Stylist-.git
   cd AI-Stylist-
   flutter create .
   flutter pub get
   ```

3. **Add camera/photo permission strings** - required by `image_picker` or
   the app will crash when opening the camera/gallery:

   - **iOS** (`ios/Runner/Info.plist`), add:
     ```xml
     <key>NSCameraUsageDescription</key>
     <string>AI Stylist needs your camera to photograph clothing items.</string>
     <key>NSPhotoLibraryUsageDescription</key>
     <string>AI Stylist needs access to your photos to add clothing items.</string>
     ```
   - **Android** (`android/app/src/main/AndroidManifest.xml`), add inside
     `<manifest>`:
     ```xml
     <uses-permission android:name="android.permission.CAMERA" />
     ```

4. Run it:

   ```bash
   flutter run
   ```

5. Once it's running, if `flutter analyze` turns up anything (version drift
   in the pinned package versions is the most likely thing after enough
   time has passed), let me know the errors and I'll fix them.

## Roadmap ideas

- Automatic color/category tagging from the photo itself (vision model)
  instead of manual tagging.
- Weather- or occasion-aware outfit suggestions.
- Save/favorite generated outfits and build a wear history.
- Cloud sync/backup of the closet.
