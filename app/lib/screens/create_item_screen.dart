import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/components/item_form_body.dart';
import 'package:shareloop/screens/location_picker_screen.dart';
import 'package:shareloop/screens/login_screen.dart';
import 'package:shareloop/screens/item_screen.dart';
import 'package:shareloop/state/auth.dart' show authProvider;
import 'package:shareloop/state/item_form.dart';
import 'package:shareloop/state/items.dart';
import 'package:shareloop/state/location.dart' show currentPositionProvider;
import 'package:shareloop/state/location_search.dart';
import 'package:shareloop/state/token_storage.dart' show getAccessToken;
import 'package:shareloop/app_config.dart';

class CreateItemScreen extends ConsumerStatefulWidget {
  const CreateItemScreen({super.key});

  @override
  ConsumerState<CreateItemScreen> createState() => _CreateItemScreenState();

  static Future<void> push(BuildContext ctx) async {
    await Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => const CreateItemScreen()),
    );
  }
}

class _CreateItemScreenState extends ConsumerState<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  bool _loading = false;
  bool _redirectedToLoginScreen = false;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(itemFormProvider);
    _titleController.text = saved.title;
    _descriptionController.text = saved.description;
    _category = saved.category;
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
      debugPrint('[createItem] No token available');
    }

    setState(() => _loading = true);
    try {
      final request = CreateItemRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        city: city ?? '',
        postalCode: postalCode ?? '',
        lat: lat,
        lng: lng,
      );

      debugPrint('[createItem] Creating item...');
      final result = await AppConfig.apiClient.createItem(request);
      debugPrint('[createItem] Response: $result');

      if (result != null && mounted) {
        final itemId = result.id;

        final state = ref.read(itemFormProvider);
        if (state.images.whereType<LocalItemImage>().isNotEmpty) {
          debugPrint(
            '[createItem] Uploading ${state.images.whereType<LocalItemImage>().length} image(s)...',
          );
          try {
            for (var i = 0; i < state.images.length; i++) {
              final img = state.images[i];
              if (img is LocalItemImage) {
                final uuid = await uploadImage(itemId, img.file, i);
                debugPrint('[createItem] Uploaded image: $uuid');
              }
            }
          } catch (e) {
            debugPrint('[createItem] Image upload failed (continuing): $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Einige Bilder konnten nicht hochgeladen werden: $e',
                  ),
                ),
              );
            }
          }
        }

        ref.read(itemFormProvider.notifier).reset();
        ref.invalidate(featuredItemsProvider);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ItemScreen(itemId: itemId)),
          );
        }
      } else if (result == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler: Keine Antwort vom Server.')),
        );
      }
    } on ApiException catch (e) {
      debugPrint(
        '[createItem] ApiException: code=${e.code}, message=${e.message}',
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
    final formState = ref.watch(itemFormProvider);
    final locationLabel = _locationLabel();

    return Scaffold(
      appBar: AppBar(title: const Text('Inserat erstellen')),
      body: authAsync.when(
        skipLoadingOnReload: true,
        data: (user) {
          if (user == null) {
            if (!_redirectedToLoginScreen) {
              _redirectedToLoginScreen = true;
              LoginScreen.queuePush(context);
            }
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Du musst angemeldet sein, um ein Inserat zu erstellen.',
                  ),
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
          return ItemFormBody(
            formKey: _formKey,
            titleController: _titleController,
            descriptionController: _descriptionController,
            category: _category,
            onCategoryChanged: (v) {
              setState(() => _category = v);
              ref.read(itemFormProvider.notifier).setCategory(v);
            },
            locationLabel: locationLabel,
            onLocationTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
            ),
            images: formState.images,
            onReorderImages: (oldIndex, newIndex) {
              ref.read(itemFormProvider.notifier).moveImage(oldIndex, newIndex);
            },
            onRemoveImage: (i) {
              ref.read(itemFormProvider.notifier).removeImage(i);
            },
            onAddImage: (file) {
              ref.read(itemFormProvider.notifier).addImage(file);
            },
            onSubmit: _submit,
            isLoading: _loading,
            isEdit: false,
          );
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
}
