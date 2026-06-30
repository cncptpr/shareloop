import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/item_form.dart';

class ItemFormBody extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? category;
  final ValueChanged<String?> onCategoryChanged;
  final String? locationLabel;
  final VoidCallback onLocationTap;
  final List<ItemImage> images;
  final void Function(int oldIndex, int newIndex) onReorderImages;
  final ValueChanged<int> onRemoveImage;
  final ValueChanged<XFile> onAddImage;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool isEdit;

  const ItemFormBody({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.category,
    required this.onCategoryChanged,
    required this.locationLabel,
    required this.onLocationTap,
    required this.images,
    required this.onReorderImages,
    required this.onRemoveImage,
    required this.onAddImage,
    required this.onSubmit,
    required this.isLoading,
    required this.isEdit,
  });

  @override
  State<ItemFormBody> createState() => _ItemFormBodyState();
}

class _ItemFormBodyState extends State<ItemFormBody> {
  final _picker = ImagePicker();
  bool _dropHovering = false;

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: kIsWeb ? null : 1024,
    );
    if (file != null) {
      widget.onAddImage(file);
    }
  }

  void _onDrop(DropDoneDetails details) {
    for (final file in details.files) {
      final ext = file.name.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
        widget.onAddImage(XFile(file.path));
      }
    }
    setState(() => _dropHovering = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: widget.titleController,
            decoration: const InputDecoration(
              labelText: 'Titel',
            ),
            validator: (v) {
              return (v == null || v.trim().isEmpty) ? 'Erforderlich' : null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Beschreibung',
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (v) {
              return (v == null || v.trim().isEmpty) ? 'Erforderlich' : null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: (widget.category ?? '').isEmpty ? null : widget.category,
            decoration: const InputDecoration(
              labelText: 'Kategorie',
            ),
            items: dummyCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: widget.onCategoryChanged,
            validator: (v) {
              return (v == null || v.isEmpty) ? 'Erforderlich' : null;
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.onLocationTap,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Standort',
                suffixIcon: Icon(Icons.location_on),
              ),
              child: Text(
                widget.locationLabel ?? 'Tippen zum Wählen',
                style: TextStyle(
                  color: widget.locationLabel != null
                      ? null
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.images.isNotEmpty) _imageRondell(),
          const SizedBox(height: 8),
          _dropTarget(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.isEdit ? 'Speichern' : 'Inserat aufgeben'),
          ),
        ],
      ),
    );
  }

  Widget _imageRondell() {
    return SizedBox(
      height: 120,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        onReorder: widget.onReorderImages,
        proxyDecorator: (child, index, animation) => Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: child,
        ),
        itemBuilder: (ctx, i) {
          final img = widget.images[i];
          return Stack(
            key: ValueKey(_imageKey(img)),
            children: [
              _ItemFormImageTile(image: img),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => widget.onRemoveImage(i),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dropTarget() {
    return DropTarget(
      onDragEntered: (_) => setState(() => _dropHovering = true),
      onDragExited: (_) => setState(() => _dropHovering = false),
      onDragDone: _onDrop,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          border: Border.all(
            color: _dropHovering
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _dropHovering
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  tooltip: 'Kamera',
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  tooltip: 'Galerie',
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _dropHovering
                  ? 'Loslassen zum Hinzufügen'
                  : 'Bilder wählen oder hierher ziehen',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _imageKey(ItemImage img) {
    if (img is ServerItemImage) return 'server:${img.uuid}';
    return 'local:${(img as LocalItemImage).file.path}';
  }
}

class _ItemFormImageTile extends StatelessWidget {
  final ItemImage image;

  const _ItemFormImageTile({required this.image});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    Widget? overlay;

    if (image is ServerItemImage) {
      final srv = image as ServerItemImage;
      imageWidget = Image.network(
        AppConfig.imageUrl(srv.uuid),
        height: 120,
        width: 120,
        fit: BoxFit.cover,
      );
      overlay = Positioned(
        top: 4,
        left: 4,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.cloud, color: Colors.white, size: 14),
        ),
      );
    } else {
      final local = image as LocalItemImage;
      imageWidget = kIsWeb
          ? Image.network(
              local.file.path,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(local.file.path),
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            );
    }

    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget),
        if (overlay != null) overlay,
      ],
    );
  }
}
