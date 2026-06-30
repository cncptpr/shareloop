import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart' show UpdateUserProfileRequest, UploadItemImageRequest, UserProfile;
import 'package:shareloop/app_config.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

  static Future<bool?> push(BuildContext ctx, UserProfile profile) async {
    if (!ctx.mounted) return null;
    return Navigator.push<bool>(
      ctx,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  bool _loading = false;
  XFile? _newAvatar;
  bool _removeAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 1024);
    if (file != null) {
      setState(() {
        _newAvatar = file;
        _removeAvatar = false;
      });
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = widget.profile.avatarUuid != null && !_removeAvatar;
    final previewImage = _newAvatar != null
        ? Image.file(File(_newAvatar!.path), width: 96, height: 96, fit: BoxFit.cover)
        : null;
    final initials = (widget.profile.name.isNotEmpty
            ? widget.profile.name[0].toUpperCase()
            : '?');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil bearbeiten'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: previewImage != null
                        ? null
                        : (hasAvatar
                            ? NetworkImage(
                                '${AppConfig.apiBaseUrl}/images/${widget.profile.avatarUuid}')
                            : null),
                    child: previewImage ?? (hasAvatar ? null : Text(initials, style: const TextStyle(fontSize: 36))),
                  ),
                  if (previewImage != null)
                    ClipOval(
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: previewImage,
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: _showImageSourceSheet,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasAvatar || _newAvatar != null)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Bild entfernen'),
                  onPressed: () {
                    setState(() {
                      _newAvatar = null;
                      _removeAvatar = true;
                    });
                  },
                ),
              ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name erforderlich' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final userId = widget.profile.id;

      if (_removeAvatar && widget.profile.avatarUuid != null) {
        await AppConfig.apiClient.deleteUserAvatar(userId);
      }

      if (_newAvatar != null) {
        final bytes = await _newAvatar!.readAsBytes();
        final data = base64.encode(bytes);
        final request = UploadItemImageRequest(
          data: data,
          filename: _newAvatar!.name,
          sortOrder: 0,
        );
        await AppConfig.apiClient.uploadUserAvatar(userId, request);
      }

      final profileRequest = UpdateUserProfileRequest(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      );
      await AppConfig.apiClient.updateUserProfile(userId, profileRequest);

      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Speichern')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
