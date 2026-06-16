import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/location_search.dart';
import 'package:uuid/uuid.dart';

const dummyCategories = [
  'Elektronik',
  'Möbel',
  'Kleidung',
  'Bücher',
  'Sport',
  'Sonstiges',
];

sealed class ItemImage {}

class LocalItemImage implements ItemImage {
  final XFile file;
  LocalItemImage({required this.file});
}

class ServerItemImage implements ItemImage {
  final UuidValue uuid;

  ServerItemImage({required this.uuid});

  ServerItemImage markDeleted() => ServerItemImage(uuid: uuid);
}

class ItemFormState {
  final String title;
  final String description;
  final String? category;
  final List<ItemImage> images;
  final List<UuidValue> deletedServerImages;
  final SelectedLocation? selectedLocation;

  const ItemFormState({
    this.title = '',
    this.description = '',
    this.category,
    this.images = const [],
    this.deletedServerImages = const [],
    this.selectedLocation,
  });

  ItemFormState copyWith({
    String? title,
    String? description,
    String? category,
    List<ItemImage>? images,
    List<UuidValue>? deletedServerImages,
    SelectedLocation? selectedLocation,
  }) {
    return ItemFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
      deletedServerImages: deletedServerImages ?? this.deletedServerImages,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}

class ItemFormNotifier extends Notifier<ItemFormState> {
  @override
  ItemFormState build() => const ItemFormState();

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setCategory(String? v) => state = state.copyWith(category: v);
  void setSelectedLocation(SelectedLocation? v) =>
      state = state.copyWith(selectedLocation: v);
  void addImage(XFile img) {
    state = state.copyWith(images: [
      ...state.images,
      LocalItemImage(file: img),
    ]);
  }

  void removeImage(int index) {
    final img = state.images[index];
    final updated = [...state.images]..removeAt(index);
    if (img is ServerItemImage) {
      state = state.copyWith(
        images: updated,
        deletedServerImages: [...state.deletedServerImages, img.uuid],
      );
    } else {
      state = state.copyWith(images: updated);
    }
  }

  void moveImage(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final updated = [...state.images];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = state.copyWith(images: updated);
  }

  void reset() => state = const ItemFormState();
}

final itemFormProvider = NotifierProvider<ItemFormNotifier, ItemFormState>(
  ItemFormNotifier.new,
);

class EditItemFormNotifier extends ItemFormNotifier {
  final ItemEditDetail _item;

  EditItemFormNotifier({required ItemEditDetail item}) : _item = item;

  @override
  ItemFormState build() {
    SearchedLocation? location;
    if (_item.lat != null && _item.lng != null) {
      final city = _item.city ?? '';
      final postalCode = _item.postalCode ?? '';
      final parts = [postalCode, city]..removeWhere((s) => s.isEmpty);
      final name = parts.isEmpty ? '${_item.lat}, ${_item.lng}' : parts.join(' ');
      location = SearchedLocation(
        name: name,
        displayName: name,
        lat: _item.lat!,
        lng: _item.lng!,
        city: city,
        postalCode: postalCode,
      );
    }
    return ItemFormState(
      title: _item.title,
      description: _item.description,
      images: _item.imageUuids
          .map((uuid) => ServerItemImage(uuid: UuidValue.fromString(uuid)))
          .toList(),
      selectedLocation: location,
    );
  }
}

final editItemFormProvider =
    NotifierProvider.family<EditItemFormNotifier, ItemFormState, ItemEditDetail>(
  (arg) => EditItemFormNotifier(item: arg),
);

Future<int?> createItem(CreateItemRequest request) async {
  debugPrint('[createItem] Sending request: ${request.toJson()}');
  final result = await AppConfig.apiClient.createItem(request);
  debugPrint('[createItem] Response: $result');
  return result?.id;
}

Future<String> uploadImage(int itemId, XFile file, int sortOrder) async {
  final bytes = await file.readAsBytes();
  final data = base64.encode(bytes);
  final request = UploadItemImageRequest(
    data: data,
    filename: file.name,
    sortOrder: sortOrder,
  );
  debugPrint(
    '[uploadImage] Uploading ${file.name} for item $itemId (order: $sortOrder)',
  );
  final result = await AppConfig.apiClient.uploadItemImage(itemId, request);
  debugPrint('[uploadImage] Response: $result');
  return result!.uuid;
}

Future<CreateItemResponse?> updateItem(
  int itemId,
  UpdateItemRequest request,
) async {
  debugPrint('[updateItem] Sending request: ${request.toJson()}');
  final result = await AppConfig.apiClient.updateItem(itemId, request);
  debugPrint('[updateItem] Response: $result');
  return result;
}

Future<void> editItemImages(int itemId, EditItemImagesRequest request) async {
  debugPrint('[editItemImages] Sending request: ${request.toJson()}');
  await AppConfig.apiClient.editItemImages(itemId, request);
  debugPrint('[editItemImages] Done');
}

String imageUrl(String uuid) => '${AppConfig.apiBaseUrl}/images/$uuid';
