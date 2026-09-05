import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../providers/closet_provider.dart';
import '../services/outfit_matcher.dart';
import '../widgets/empty_state.dart';

class OutfitScreen extends StatefulWidget {
  const OutfitScreen({super.key});

  @override
  State<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends State<OutfitScreen> {
  final OutfitMatcher _matcher = OutfitMatcher();
  Outfit? _outfit;
  bool _hasGenerated = false;

  void _shuffle(List<ClothingItem> closetItems) {
    setState(() {
      _outfit = _matcher.generate(closetItems);
      _hasGenerated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final closet = context.watch<ClosetProvider>();

    if (!_hasGenerated && !closet.isLoading) {
      // Generate the first outfit as soon as the closet is available.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasGenerated) {
          _shuffle(closet.items);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s outfit')),
      body: closet.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _outfit == null
              ? EmptyState(
                  icon: Icons.checkroom_outlined,
                  title: 'Not enough pieces yet',
                  message: 'Add at least a top and a bottom (or a dress) so an outfit can be put together.',
                  actionLabel: 'Back to closet',
                  onAction: () => Navigator.of(context).pop(),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    for (final item in _outfit!.pieces)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 1.3,
                                child: Image.file(File(item.imagePath), fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(item.category.icon, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: item.color.swatch,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
      floatingActionButton: closet.isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _shuffle(closet.items),
              icon: const Icon(Icons.shuffle),
              label: const Text('Shuffle'),
            ),
    );
  }
}
