import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/components/item_form_body.dart';
import 'package:shareloop/components/location_form_mixin.dart';
import 'package:shareloop/state/item_form.dart';
import 'package:shareloop/state/items.dart';
import 'package:shareloop/state/location_search.dart';
import 'package:shareloop/app_config.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final ItemDetail existingItem;

  const EditItemScreen({super.key, required this.existingItem});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();

  static Future<bool?> push(BuildContext ctx, ItemDetail item) {
    return Navigator.push<bool>(
      ctx,
      MaterialPageRoute(builder: (_) => EditItemScreen(existingItem: item)),
    );
  }
}

class _EditItemScreenState extends ConsumerState<EditItemScreen>
    with LocationFormMixin<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  bool _loading = false;
  SearchedLocation? _selectedLocation;

  @override
  SearchedLocation? get selectedLocation => _selectedLocation;

  @override
  set selectedLocation(SearchedLocation? value) =>
      setState(() => _selectedLocation = value);

  @override
  void setProviderLocation(SelectedLocation? loc) {
    ref.read(editItemFormProvider(widget.existingItem).notifier)
        .setSelectedLocation(loc);
  }

  @override
  void initState() {
    super.initState();
    final formState = ref.read(editItemFormProvider(widget.existingItem));
    _titleController.text = formState.title.isNotEmpty
        ? formState.title
        : widget.existingItem.title;
    _descriptionController.text = formState.description.isNotEmpty
        ? formState.description
        : widget.existingItem.description;
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
    _selectedLocation = formState.selectedLocation is SearchedLocation
        ? formState.selectedLocation as SearchedLocation
        : null;
  }

  void _onTitleChanged() {
    ref
        .read(editItemFormProvider(widget.existingItem).notifier)
        .setTitle(_titleController.text);
  }

  void _onDescriptionChanged() {
    ref
        .read(editItemFormProvider(widget.existingItem).notifier)
        .setDescription(_descriptionController.text);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    var selected = _selectedLocation;
    if (selected == null || selected.city.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte wähle einen Standort.')),
        );
      }
      return;
    }
    if (selected.postalCode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Der gewählte Standort hat keine Postleitzahl. Bitte wähle einen anderen Standort.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      await _submitEdit(selected);
    } on ApiException catch (e) {
      debugPrint(
        '[editItem] ApiException: code=${e.code}, message=${e.message}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fehler ${e.code}: ${e.message ?? 'Unbekannter Fehler'}',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('[editItem] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitEdit(SearchedLocation location) async {
    final itemId = widget.existingItem.id;
    final state = ref.read(editItemFormProvider(widget.existingItem));

    List<Future> futures = [];

    final delete = state.deletedServerImages.map((e) => e.toString()).toList();

    final reorder = <ReorderEntry>[];
    for (final (i, img) in state.images.indexed) {
      if (img is LocalItemImage) {
        futures.add(uploadImage(itemId, img.file, i));
      } else if (img is ServerItemImage) {
        reorder.add(ReorderEntry(uuid: img.uuid.toString(), sortOrder: i));
      }
    }

    final textRequest = UpdateItemRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      city: location.city,
      postalCode: location.postalCode,
      lat: location.lat,
      lng: location.lng,
    );

    final imagesRequest = EditItemImagesRequest(
      reorder: reorder,
      delete: delete,
    );

    debugPrint('[editItem] Updating item $itemId...');
    final textFuture = AppConfig.apiClient.updateItem(itemId, textRequest);
    final imagesFuture = AppConfig.apiClient.editItemImages(
      itemId,
      imagesRequest,
    );

    await Future.wait([...futures, textFuture, imagesFuture]);
    debugPrint('[editItem] Update done');

    ref.read(editItemFormProvider(widget.existingItem).notifier).reset();
    ref.invalidate(featuredItemsProvider);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = editItemFormProvider(widget.existingItem);
    final formState = ref.watch(provider);
    final label = locationLabel();

    return Scaffold(
      appBar: AppBar(title: const Text('Inserat bearbeiten')),
      body: ItemFormBody(
        formKey: _formKey,
        titleController: _titleController,
        descriptionController: _descriptionController,
        category: _category,
        onCategoryChanged: (v) => setState(() => _category = v),
        locationLabel: label,
        onLocationTap: openLocationPicker,
        images: formState.images,
        onReorderImages: (oldIndex, newIndex) {
          ref.read(provider.notifier).moveImage(oldIndex, newIndex);
        },
        onRemoveImage: (i) => ref.read(provider.notifier).removeImage(i),
        onAddImage: (file) => ref.read(provider.notifier).addImage(file),
        onSubmit: _submit,
        isLoading: _loading,
        isEdit: true,
      ),
    );
  }
}
