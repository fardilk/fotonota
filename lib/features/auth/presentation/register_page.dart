import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/config/providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return 'Confirm password';
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _submitting = true; _error = null; });
    try {
      final id = await ref.read(authServiceProvider).register(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registered (id=$id). Please login.')),
      );
      Navigator.pop(context); // back to login
    } catch (e) {
      setState(() {
        // Basic conflict detection (Dio error with 409)
        final msg = e.toString();
        if (msg.contains('409')) {
          _error = 'Username already exists';
        } else {
          _error = 'Registration failed';
        }
      });
    } finally {
      if (mounted) setState(() { _submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftarkan Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              FormCard(
                child: Column(
                  children: [
                    LabeledTextField(label: 'Username', controller: _usernameCtrl, prefixIcon: const Icon(Icons.person)),
                    const SizedBox(height: 12),
                    LabeledTextField(label: 'Password', controller: _passwordCtrl, obscureText: true, prefixIcon: const Icon(Icons.lock)),
                    const SizedBox(height: 12),
                    LabeledTextField(label: 'Confirm Password', controller: _confirmCtrl, obscureText: true, prefixIcon: const Icon(Icons.lock_outline), validator: _confirmValidator),
                    const SizedBox(height: 16),
                    FormActions(label: _submitting ? 'Registering...' : 'Register', loading: _submitting, onPressed: _submitting ? (){} : _submit),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    const SizedBox(height: 8),
                    TextButton(onPressed: _submitting ? null : () => Navigator.pop(context), child: const Text('Back to Login')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
