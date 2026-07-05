import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/state/auth.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      ref.invalidate(authProvider);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (e.code == 409) {
        setState(() => _error = 'E-Mail bereits registriert.');
      } else {
        setState(() => _error = 'Registrierung fehlgeschlagen. Bitte versuche es erneut.');
      }
    } catch (_) {
      setState(() => _error = 'Verbindungsfehler. Bitte versuche es erneut.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konto erstellen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Erforderlich' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Erforderlich';
                    if (!_emailRegex.hasMatch(v.trim())) {
                      return 'Gib eine gültige E-Mail-Adresse ein';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Passwort'),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Erforderlich';
                    if (v.length < 6) return 'Mindestens 6 Zeichen';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Konto erstellen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
