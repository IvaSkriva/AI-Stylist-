import 'dart:math';

import '../models/clothing_category.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

/// Rule-based outfit generator.
///
/// This is intentionally a simple heuristic (category slots + a curated
/// color-compatibility table) rather than a real computer-vision model, so
/// the app is useful from the very first commit. The natural place to plug
/// in real "AI" later is [_colorPairScore]/[generate]: swap the scoring
/// function for one backed by a vision model that extracts dominant colors
/// and style tags automatically when a photo is added.
class OutfitMatcher {
  OutfitMatcher({Random? random}) : _random = random ?? Random();

  static const int _candidateCount = 30;

  final Random _random;

  static final List<Set<ClothingColor>> _complementaryPairs = <Set<ClothingColor>>[
    <ClothingColor>{ClothingColor.red, ClothingColor.green},
    <ClothingColor>{ClothingColor.blue, ClothingColor.orange},
    <ClothingColor>{ClothingColor.yellow, ClothingColor.purple},
    <ClothingColor>{ClothingColor.pink, ClothingColor.green},
  ];

  /// Returns the best-scoring outfit found across [_candidateCount] random
  /// candidates, or `null` if the closet doesn't have enough pieces yet
  /// (at minimum one top+bottom pair, or one dress).
  Outfit? generate(List<ClothingItem> closet) {
    final tops = _forCategory(closet, ClothingCategory.top);
    final bottoms = _forCategory(closet, ClothingCategory.bottom);
    final dresses = _forCategory(closet, ClothingCategory.dress);
    final outerwear = _forCategory(closet, ClothingCategory.outerwear);
    final shoes = _forCategory(closet, ClothingCategory.shoes);
    final accessories = _forCategory(closet, ClothingCategory.accessory);

    final canDoTopBottom = tops.isNotEmpty && bottoms.isNotEmpty;
    final canDoDress = dresses.isNotEmpty;

    if (!canDoTopBottom && !canDoDress) {
      return null;
    }

    Outfit? best;
    double bestScore = double.negativeInfinity;

    for (var i = 0; i < _candidateCount; i++) {
      final useDress = canDoDress && (!canDoTopBottom || _random.nextBool());

      final candidate = useDress
          ? Outfit(
              dress: _pick(dresses),
              outerwear: _maybePick(outerwear, chance: 0.4),
              shoes: shoes.isEmpty ? null : _pick(shoes),
              accessory: _maybePick(accessories, chance: 0.5),
            )
          : Outfit(
              top: _pick(tops),
              bottom: _pick(bottoms),
              outerwear: _maybePick(outerwear, chance: 0.4),
              shoes: shoes.isEmpty ? null : _pick(shoes),
              accessory: _maybePick(accessories, chance: 0.5),
            );

      final score = _score(candidate);
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }

    return best;
  }

  List<ClothingItem> _forCategory(List<ClothingItem> closet, ClothingCategory category) {
    return closet.where((item) => item.category == category).toList();
  }

  T _pick<T>(List<T> options) => options[_random.nextInt(options.length)];

  T? _maybePick<T>(List<T> options, {required double chance}) {
    if (options.isEmpty || _random.nextDouble() > chance) {
      return null;
    }
    return _pick(options);
  }

  double _score(Outfit outfit) {
    final colors = outfit.pieces.map((item) => item.color).toList();
    var score = 0.0;
    for (var i = 0; i < colors.length; i++) {
      for (var j = i + 1; j < colors.length; j++) {
        score += _colorPairScore(colors[i], colors[j]);
      }
    }
    return score;
  }

  double _colorPairScore(ClothingColor a, ClothingColor b) {
    if (a == b) {
      return 2;
    }
    if (a.isNeutral || b.isNeutral) {
      return 1.5;
    }
    final pair = <ClothingColor>{a, b};
    final isComplementary = _complementaryPairs.any(
      (candidate) => candidate.length == pair.length && candidate.containsAll(pair),
    );
    return isComplementary ? 1 : 0;
  }
}
