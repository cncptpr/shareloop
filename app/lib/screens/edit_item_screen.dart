// See docs/item-edit-create-flow.md — Riverpod provider is the single source of truth.
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
  final int itemId;

  const EditItemScreen({super.key, required this.itemId});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();

  static Future<bool?> push(BuildContext ctx, int itemId) async {
    if (!ctx.mounted) return null;
    return Navigator.push<bool>(
      ctx,
      MaterialPageRoute(
        builder: (_) => EditItemScreen(itemId: itemId),
      ),
    );
  }
}

class _EditItemScreenState extends ConsumerState<EditItemScreen>
    with LocationFormMixin<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _loading = false;
  bool _initializedControllers = false;

  @override
  SearchedLocation? get selectedLocation {
    final s = ref.read(editItemFormProvider(widget.itemId)).selectedLocation;
    return s is SearchedLocation ? s : null;
  }

  @override
  set selectedLocation(SearchedLocation? value) {
    ref
        .read(editItemFormProvider(widget.itemId).notifier)
        .setSelectedLocation(value);
  }

  void _onFormStateChange(ItemFormState? prev, ItemFormState next) {
    if (!_initializedControllers && next.title.isNotEmpty) {
      _initializedControllers = true;
      _titleController.text = next.title;
      _descriptionController.text = next.description;
      if (next.pricePerDay != null) {
        _priceController.text = next.pricePerDay.toString();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final formState = ref.read(editItemFormProvider(widget.itemId));
    if (formState.title.isNotEmpty) {
      _titleController.text = formState.title;
      _descriptionController.text = formState.description;
      _initializedControllers = true;
    }
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
    _priceController.addListener(_onPriceChanged);
  }

  void _onTitleChanged() {
    ref
        .read(editItemFormProvider(widget.itemId).notifier)
        .setTitle(_titleController.text);
  }

  void _onDescriptionChanged() {
    ref
        .read(editItemFormProvider(widget.itemId).notifier)
        .setDescription(_descriptionController.text);
  }

  void _onPriceChanged() {
    final text = _priceController.text.trim();
    ref.read(editItemFormProvider(widget.itemId).notifier).setPricePerDay(
      text.isEmpty ? null : double.tryParse(text),
    );
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _priceController.removeListener(_onPriceChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final formState = ref.read(editItemFormProvider(widget.itemId));
    final selected = formState.selectedLocation is SearchedLocation
        ? formState.selectedLocation as SearchedLocation
        : null;
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
    final itemId = widget.itemId;
    final state = ref.read(editItemFormProvider(widget.itemId));

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
      title: state.title,
      description: state.description,
      category: state.category,
      city: location.city,
      postalCode: location.postalCode,
      lat: location.lat,
      lng: location.lng,
      pricePerDay: state.pricePerDay!,
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

    ref.invalidate(featuredItemsProvider);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(editItemFormProvider(widget.itemId), _onFormStateChange);
    final provider = editItemFormProvider(widget.itemId);
    final formState = ref.watch(provider);
    final label = locationLabel();

    return Scaffold(
      appBar: AppBar(title: const Text('Inserat bearbeiten')),
      body: ItemFormBody(
        formKey: _formKey,
        titleController: _titleController,
        descriptionController: _descriptionController,
        priceController: _priceController,
        category: formState.category,
        onCategoryChanged: (v) {
          ref.read(provider.notifier).setCategory(v);
        },
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
