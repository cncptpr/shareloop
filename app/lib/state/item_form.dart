import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
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
  final bool deleted;

  ServerItemImage({required this.uuid, this.deleted = false});

  ServerItemImage markDeleted() => ServerItemImage(uuid: uuid, deleted: true);
}

class ItemFormState {
  final String title;
  final String description;
  final String? category;
  final List<ItemImage> images;

  const ItemFormState({
    this.title = '',
    this.description = '',
    this.category,
    this.images = const [],
  });

  ItemFormState copyWith({
    String? title,
    String? description,
    String? category,
    List<ItemImage>? images,
  }) {
    return ItemFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
    );
  }
}

class ItemFormNotifier extends Notifier<ItemFormState> {
  @override
  ItemFormState build() => const ItemFormState();

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setCategory(String? v) => state = state.copyWith(category: v);
  void addImage(XFile img) =>
      state = state.copyWith(images: [...state.images, LocalItemImage(file: img)]);
  void removeImage(int index) {
    final img = state.images[index];
    if (img is ServerItemImage) {
      final updated = [...state.images];
      updated[index] = img.markDeleted();
      state = state.copyWith(images: updated);
    } else {
      final updated = [...state.images]..removeAt(index);
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

final itemFormProvider =
    NotifierProvider<ItemFormNotifier, ItemFormState>(ItemFormNotifier.new);

class EditItemFormNotifier extends ItemFormNotifier {
  final ItemDetail _item;

  EditItemFormNotifier({required ItemDetail item}) : _item = item;

  @override
  ItemFormState build() {
    return ItemFormState(
      title: _item.title,
      description: _item.description,
      images: _item.imageUuids
          .map((uuid) => ServerItemImage(uuid: UuidValue.fromString(uuid)))
          .toList(),
    );
  }
}

final editItemFormProvider = NotifierProvider.autoDispose
    .family<EditItemFormNotifier, ItemFormState, ItemDetail>(
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
  debugPrint('[uploadImage] Uploading ${file.name} for item $itemId (order: $sortOrder)');
  final result = await AppConfig.apiClient.uploadItemImage(itemId, request);
  debugPrint('[uploadImage] Response: $result');
  return result!.uuid;
}

Future<CreateItemResponse?> updateItem(int itemId, UpdateItemRequest request) async {
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
