import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/components/item_form_body.dart';
import 'package:shareloop/screens/location_picker_screen.dart';
import 'package:shareloop/state/item_form.dart';
import 'package:shareloop/state/items.dart';
import 'package:shareloop/state/location.dart' show currentPositionProvider;
import 'package:shareloop/state/location_search.dart';
import 'package:shareloop/state/token_storage.dart' show getAccessToken;
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

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _titleController.text = item.title;
    _descriptionController.text = item.description;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _locationLabel() {
    final selected = ref.read(selectedLocationProvider);
    switch (selected) {
      case SearchedLocation l:
        return l.name;
      case GPSLocation _:
        return 'Aktuelle Position';
      default:
        return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final selected = ref.read(selectedLocationProvider);
    double? lat;
    double? lng;
    String? city;
    String? postalCode;

    switch (selected) {
      case SearchedLocation l:
        lat = l.lat;
        lng = l.lng;
        city = l.name;
        postalCode = l.displayName.split(',').first.trim();
      case GPSLocation _:
        final gps = ref.read(currentPositionProvider).asData?.value;
        if (gps != null) {
          lat = gps.latitude;
          lng = gps.longitude;
        }
      default:
    }

    if (lat == null || lng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte wähle einen Standort.')),
        );
      }
      return;
    }

    final token = await getAccessToken();
    if (token != null) {
      AppConfig.bearerAuth.accessToken = token;
    } else {
      debugPrint('[editItem] No token available');
    }

    setState(() => _loading = true);
    try {
      await _submitEdit(city!, postalCode ?? '', lat, lng);
    } on ApiException catch (e) {
      debugPrint('[editItem] ApiException: code=${e.code}, message=${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler ${e.code}: ${e.message ?? 'Unbekannter Fehler'}')),
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

  Future<void> _submitEdit(String city, String postalCode, double lat, double lng) async {
    final itemId = widget.existingItem.id;
    final state = ref.read(editItemFormProvider(widget.existingItem));

    // Step 1: Upload all LocalItemImages sequentially
    final localUploads = <int, String>{};
    for (var i = 0; i < state.images.length; i++) {
      final img = state.images[i];
      if (img is LocalItemImage) {
        final uuid = await uploadImage(itemId, img.file, i);
        localUploads[i] = uuid;
      }
    }

    // Step 2: Build final ordered UUID list
    final finalUuids = <String>[];
    for (var i = 0; i < state.images.length; i++) {
      final img = state.images[i];
      if (img is ServerItemImage && !img.deleted) {
        finalUuids.add(img.uuid.toString());
      } else if (localUploads.containsKey(i)) {
        finalUuids.add(localUploads[i]!);
      }
    }

    // Step 3 & 4: Build reorder entries and delete array
    final reorder = <ReorderEntry>[];
    final deleteUuids = <String>[];
    for (final img in state.images) {
      if (img is ServerItemImage) {
        if (img.deleted) {
          deleteUuids.add(img.uuid.toString());
        } else {
          final idx = finalUuids.indexOf(img.uuid.toString());
          if (idx >= 0) {
            reorder.add(ReorderEntry(uuid: img.uuid.toString(), sortOrder: idx));
          }
        }
      }
    }

    // Step 5: Run text update + image edit in parallel
    final textRequest = UpdateItemRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      city: city,
      postalCode: postalCode,
      lat: lat,
      lng: lng,
    );
    final imagesRequest = EditItemImagesRequest(
      reorder: reorder,
      delete: deleteUuids,
    );

    debugPrint('[editItem] Updating item $itemId...');
    final textFuture = AppConfig.apiClient.updateItem(itemId, textRequest);
    final imagesFuture = AppConfig.apiClient.editItemImages(itemId, imagesRequest);

    await Future.wait([textFuture, imagesFuture]);
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
    final locationLabel = _locationLabel();

    return Scaffold(
      appBar: AppBar(title: const Text('Inserat bearbeiten')),
      body: ItemFormBody(
        formKey: _formKey,
        titleController: _titleController,
        descriptionController: _descriptionController,
        category: _category,
        onCategoryChanged: (v) => setState(() => _category = v),
        locationLabel: locationLabel,
        onLocationTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
        ),
        images: formState.images,
        onReorderImages: (oldIndex, newIndex) =>
            ref.read(provider.notifier).moveImage(oldIndex, newIndex),
        onRemoveImage: (i) =>
            ref.read(provider.notifier).removeImage(i),
        onAddImage: (file) =>
            ref.read(provider.notifier).addImage(file),
        onSubmit: _submit,
        isLoading: _loading,
        isEdit: true,
      ),
    );
  }
}
