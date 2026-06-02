import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/screens/location_picker_screen.dart';
import 'package:shareloop/screens/login_screen.dart';
import 'package:shareloop/state/auth.dart' show authProvider;
import 'package:shareloop/state/create_item.dart';
import 'package:shareloop/state/items.dart';
import 'package:shareloop/state/location.dart' show currentPositionProvider;
import 'package:shareloop/state/location_search.dart';
import 'package:shareloop/state/token_storage.dart' show getAccessToken;
import 'package:shareloop/app_config.dart';

class CreateItemScreen extends ConsumerStatefulWidget {
  const CreateItemScreen({super.key});

  @override
  ConsumerState<CreateItemScreen> createState() => _CreateItemScreenState();

  static Future<void> push(BuildContext ctx) {
    return Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CreateItemScreen()));
  }
}

class _CreateItemScreenState extends ConsumerState<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  String? _category;
  bool _loading = false;
  bool _dropHovering = false;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(createItemFormProvider);
    if (saved.title.isNotEmpty) _titleController.text = saved.title;
    if (saved.description.isNotEmpty) _descriptionController.text = saved.description;
    if (saved.category != null) _category = saved.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveFormState() {
    ref.read(createItemFormProvider.notifier)
      ..setTitle(_titleController.text)
      ..setDescription(_descriptionController.text)
      ..setCategory(_category);
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

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 1024);
    if (file != null) {
      ref.read(createItemFormProvider.notifier).addImage(file);
    }
  }

  void _onDrop(DropDoneDetails details) {
    for (final file in details.files) {
      final ext = file.name.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
        ref.read(createItemFormProvider.notifier).addImage(XFile(file.path));
      }
    }
    setState(() => _dropHovering = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _saveFormState();

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle einen Standort.')),
      );
      return;
    }

    final token = await getAccessToken();
    if (token != null) {
      AppConfig.bearerAuth.accessToken = token;
      debugPrint('[createItem] Bearer token set');
    } else {
      debugPrint('[createItem] No token available');
    }

    setState(() => _loading = true);
    try {
      final request = CreateItemRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        city: city!,
        postalCode: postalCode ?? '',
        lat: lat,
        lng: lng,
      );

      debugPrint('[createItem] Submitting item...');
      final result = await AppConfig.apiClient.createItem(request);
      debugPrint('[createItem] API response: $result');

      if (result != null && mounted) {
        final itemId = result.id;

        // Upload pending images
        final images = ref.read(createItemFormProvider).images;
        if (images.isNotEmpty) {
          debugPrint('[createItem] Uploading ${images.length} image(s)...');
          try {
            for (var i = 0; i < images.length; i++) {
              final uuid = await uploadImage(itemId, images[i], i);
              ref.read(createItemFormProvider.notifier).addUploadedUuid(uuid);
              debugPrint('[createItem] Uploaded image: $uuid');
            }
          } catch (e) {
            debugPrint('[createItem] Image upload failed (continuing): $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Einige Bilder konnten nicht hochgeladen werden: $e')),
              );
            }
          }
        }

        ref.read(createItemFormProvider.notifier).reset();
        ref.invalidate(featuredItemsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inserat erstellt!')),
          );
          Navigator.pop(context);
        }
      } else if (result == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler: Keine Antwort vom Server.')),
        );
      }
    } on ApiException catch (e) {
      debugPrint('[createItem] ApiException: code=${e.code}, message=${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler ${e.code}: ${e.message ?? 'Unbekannter Fehler'}')),
        );
      }
    } catch (e) {
      debugPrint('[createItem] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final formState = ref.watch(createItemFormProvider);
    final locationLabel = _locationLabel();

    return Scaffold(
      appBar: AppBar(title: const Text('Inserat erstellen')),
      body: authAsync.when(
        skipLoadingOnReload: true,
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Du musst angemeldet sein, um ein Inserat zu erstellen.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await LoginScreen.push(context);
                      ref.invalidate(authProvider);
                    },
                    child: const Text('Anmelden'),
                  ),
                ],
              ),
            );
          }
          return _buildForm(context, formState, locationLabel);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fehler: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(authProvider),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, CreateItemFormState formState, String? locationLabel) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titel',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _saveFormState(),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Erforderlich' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Beschreibung',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            onChanged: (_) => _saveFormState(),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Erforderlich' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Kategorie',
              border: OutlineInputBorder(),
            ),
            items: dummyCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              setState(() => _category = v);
              _saveFormState();
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              _saveFormState();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LocationPickerScreen(),
                ),
              );
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Standort',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.location_on),
              ),
              child: Text(
                locationLabel ?? 'Tippen zum Wählen',
                style: TextStyle(
                  color: locationLabel != null ? null : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (formState.images.isNotEmpty)
            SizedBox(
              height: 120,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: formState.images.length,
                onReorder: (oldIndex, newIndex) {
                  ref.read(createItemFormProvider.notifier).moveImage(oldIndex, newIndex);
                },
                proxyDecorator: (child, index, animation) => Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                ),
                itemBuilder: (ctx, i) {
                  final img = formState.images[i];
                  return Stack(
                    key: ValueKey('${img.path}_$i'),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(img.path),
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => ref.read(createItemFormProvider.notifier).removeImage(i),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            ),
          const SizedBox(height: 8),
          DropTarget(
            onDragEntered: (_) => setState(() => _dropHovering = true),
            onDragExited: (_) => setState(() => _dropHovering = false),
            onDragDone: _onDrop,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _dropHovering ? Theme.of(context).colorScheme.primary : Colors.grey,
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
                    _dropHovering ? 'Loslassen zum Hinzufügen' : 'Bilder wählen oder hierher ziehen',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          // TODO: Upload pictures to server when endpoint is available
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Inserat aufgeben'),
          ),
        ],
      ),
    );
  }
}
