import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/clothing_category.dart';
import '../models/clothing_item.dart';
import '../providers/closet_provider.dart';
import '../widgets/clothing_card.dart';
import '../widgets/empty_state.dart';
import 'add_item_screen.dart';
import 'outfit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ClothingCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClosetProvider>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Closet'),
        actions: [
          IconButton(
            tooltip: 'Generate outfit',
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OutfitScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ClosetProvider>(
        builder: (context, closet, _) {
          if (closet.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (closet.items.isEmpty) {
            return EmptyState(
              icon: Icons.checkroom_outlined,
              title: 'Your closet is empty',
              message: 'Add a photo of a clothing item to get started.',
              actionLabel: 'Add your first item',
              onAction: () => _openAddItem(context),
            );
          }

          final visibleItems = _selectedCategory == null
              ? closet.items
              : closet.itemsInCategory(_selectedCategory!);

          return Column(
            children: [
              _CategoryFilterBar(
                selected: _selectedCategory,
                onSelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              Expanded(
                child: visibleItems.isEmpty
                    ? const EmptyState(
                        icon: Icons.filter_alt_off_outlined,
                        title: 'Nothing here yet',
                        message: 'No items in this category yet.',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: visibleItems.length,
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          return ClothingCard(
                            item: item,
                            onLongPress: () => _confirmDelete(context, item),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddItem(context),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add item'),
      ),
    );
  }

  void _openAddItem(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ClothingItem item) async {
    final closet = context.read<ClosetProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove item?'),
        content: Text('"${item.name}" will be removed from your closet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await closet.removeItem(item);
    }
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.selected, required this.onSelected});

  final ClothingCategory? selected;
  final ValueChanged<ClothingCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final category in ClothingCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.label),
                selected: selected == category,
                onSelected: (_) => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }
}
