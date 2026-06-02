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

  const CreateItemFormState({
    this.title = '',
    this.description = '',
    this.category,
    this.images = const [],
  });

  CreateItemFormState copyWith({
    String? title,
    String? description,
    String? category,
    List<XFile>? images,
  }) {
    return CreateItemFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
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
