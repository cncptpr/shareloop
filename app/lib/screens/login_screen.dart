import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart' show ApiException;
import 'package:shareloop/screens/register_screen.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/token_storage.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();

  static Future<void> push(BuildContext ctx) async {
    await Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  /// For pushing during e.g. a build phase.
  static Future<void> queuePush(BuildContext ctx) async {
    WidgetsBinding.instance.addPostFrameCallback((_) => push(ctx));
  }
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _emailController.text = 'dev@example.com';
      _passwordController.text = 'dev';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await login(_emailController.text.trim(), _passwordController.text);
      ref.invalidate(authProvider);
      if (mounted) Navigator.pop(context);
    } on UnauthorizedException {
      setState(() => _error = 'Ungültige Anmeldedaten.');
    } on ApiException catch (e) {
      setState(() => _error = 'Serverfehler (${e.code}). Bitte versuche es erneut.');
    } catch (e) {
      setState(() => _error = 'Verbindungsfehler. Bitte versuche es erneut.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anmelden')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Erforderlich' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Passwort'),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Erforderlich' : null,
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
                      : const Text('Anmelden'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  ),
                  child: const Text('Konto erstellen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
