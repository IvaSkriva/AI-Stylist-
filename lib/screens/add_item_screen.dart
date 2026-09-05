import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/clothing_category.dart';
import '../providers/closet_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  String? _pickedImagePath;
  ClothingCategory _category = ClothingCategory.top;
  ClothingColor _color = ClothingColor.black;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (image != null) {
        setState(() => _pickedImagePath = image.path);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the camera/gallery: $error')),
      );
    }
  }

  Future<void> _save() async {
    final imagePath = _pickedImagePath;
    if (imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a photo first.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<ClosetProvider>().addItem(
            pickedImagePath: imagePath,
            category: _category,
            color: _color,
            name: _nameController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save this item: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add clothing item')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ImagePickerPreview(
            imagePath: _pickedImagePath,
            onTakePhoto: () => _pickImage(ImageSource.camera),
            onPickFromGallery: () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: 24),
          Text('Category', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in ClothingCategory.values)
                ChoiceChip(
                  label: Text(category.label),
                  avatar: Icon(category.icon, size: 18),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Color', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final color in ClothingColor.values)
                _ColorSwatch(
                  color: color,
                  selected: _color == color,
                  onTap: () => setState(() => _color = color),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Name (optional)', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'e.g. Blue denim jacket'),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save to closet'),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerPreview extends StatelessWidget {
  const _ImagePickerPreview({
    required this.imagePath,
    required this.onTakePhoto,
    required this.onPickFromGallery,
  });

  final String? imagePath;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: imagePath == null
                ? Icon(Icons.checkroom_outlined, size: 64, color: theme.colorScheme.outline)
                : Image.file(File(imagePath!), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTakePhoto,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.selected, required this.onTap});

  final ClothingColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.swatch,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Theme.of(context).colorScheme.primary : Colors.black12,
                width: selected ? 3 : 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(color.label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
