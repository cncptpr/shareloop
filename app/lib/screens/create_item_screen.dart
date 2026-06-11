import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/components/item_form_body.dart';
import 'package:shareloop/components/location_form_mixin.dart';
import 'package:shareloop/screens/login_screen.dart';
import 'package:shareloop/screens/item_screen.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/item_form.dart';
import 'package:shareloop/state/items.dart';
import 'package:shareloop/state/location.dart';
import 'package:shareloop/state/location_search.dart';
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

class _CreateItemScreenState extends ConsumerState<CreateItemScreen>
    with LocationFormMixin<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  bool _loading = false;
  bool _redirectedToLoginScreen = false;
  SearchedLocation? _selectedLocation;

  @override
  SearchedLocation? get selectedLocation => _selectedLocation;

  @override
  set selectedLocation(SearchedLocation? value) =>
      setState(() => _selectedLocation = value);

  @override
  void setProviderLocation(SelectedLocation? loc) {
    ref.read(itemFormProvider.notifier).setSelectedLocation(loc);
  }

  @override
  void initState() {
    super.initState();
    final saved = ref.read(itemFormProvider);
    _titleController.text = saved.title;
    _descriptionController.text = saved.description;
    _category = saved.category;
    _selectedLocation = saved.selectedLocation is SearchedLocation
        ? saved.selectedLocation as SearchedLocation
        : null;
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
    if (_selectedLocation == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
    }
  }

  Future<void> _initLocation() async {
    // Try app-wide selected location first
    final global = ref.read(selectedLocationProvider);
    if (global is SearchedLocation) {
      applyLocation(global);
      return;
    }
    // Fall back to GPS reverse-geocode
    try {
      final gps = await ref.read(currentPositionProvider.future);
      if (gps == null || !mounted) return;
      final loc = await ref.read(
        reverseLocationProvider((gps.latitude, gps.longitude)).future,
      );
      if (loc == null ||
          loc.city.isEmpty ||
          loc.postalCode.isEmpty ||
          !mounted) {
        return;
      }
      applyLocation(loc);
    } catch (_) {}
  }

  void _onTitleChanged() {
    ref.read(itemFormProvider.notifier).setTitle(_titleController.text);
  }

  void _onDescriptionChanged() {
    ref
        .read(itemFormProvider.notifier)
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

    final selected = _selectedLocation;
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
      final request = CreateItemRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        city: selected.city,
        postalCode: selected.postalCode,
        lat: selected.lat,
        lng: selected.lng,
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
    final label = locationLabel();

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
            locationLabel: label,
            onLocationTap: openLocationPicker,
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
