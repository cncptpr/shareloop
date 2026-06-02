import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';

const dummyCategories = [
  'Elektronik',
  'Möbel',
  'Kleidung',
  'Bücher',
  'Sport',
  'Sonstiges',
];

class CreateItemFormState {
  final String title;
  final String description;
  final String? category;
  final List<XFile> images;
  final List<String> uploadedImageUuids;

  const CreateItemFormState({
    this.title = '',
    this.description = '',
    this.category,
    this.images = const [],
    this.uploadedImageUuids = const [],
  });

  CreateItemFormState copyWith({
    String? title,
    String? description,
    String? category,
    List<XFile>? images,
    List<String>? uploadedImageUuids,
  }) {
    return CreateItemFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
      uploadedImageUuids: uploadedImageUuids ?? this.uploadedImageUuids,
    );
  }
}

class CreateItemFormNotifier extends Notifier<CreateItemFormState> {
  @override
  CreateItemFormState build() => const CreateItemFormState();

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setCategory(String? v) => state = state.copyWith(category: v);
  void addImage(XFile img) =>
      state = state.copyWith(images: [...state.images, img]);
  void removeImage(int index) {
    final updated = [...state.images]..removeAt(index);
    state = state.copyWith(images: updated);
  }

  void moveImage(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final updated = [...state.images];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = state.copyWith(images: updated);
  }

  void addUploadedUuid(String uuid) =>
      state = state.copyWith(uploadedImageUuids: [...state.uploadedImageUuids, uuid]);

  void clearImages() => state = state.copyWith(images: []);
  void reset() => state = const CreateItemFormState();
}

final createItemFormProvider =
    NotifierProvider<CreateItemFormNotifier, CreateItemFormState>(
  CreateItemFormNotifier.new,
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

String imageUrl(String uuid) => '${AppConfig.apiBaseUrl}/images/$uuid';
