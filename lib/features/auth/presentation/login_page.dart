import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/config/providers.dart';
import '../../../core/config/route_names.dart';
import '../../dashboard/data/dashboard_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authStateProvider.notifier).login(
          _usernameCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (success && mounted) {
      // Fetch total amount and show to the user
      try {
        final total = await ref.read(catatanRepoProvider).totalAmount();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Total amount: $total')),
        );
      } catch (_) {
        // ignore errors here; proceed to dashboard
      }
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    } else if (mounted) {
      final err = ref.read(authStateProvider).error ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              AppTextField.username(controller: _usernameCtrl),
              const SizedBox(height: 16),
              AppTextField.password(
                controller: _passwordCtrl,
                onSubmit: _submit,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: authState.loading ? 'Signing In...' : 'Sign In',
                loading: authState.loading,
                onPressed: authState.loading ? null : _submit,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: authState.loading ? null : () => Navigator.pushNamed(context, RouteNames.register),
                  child: const Text('Daftarkan Akun'),
                ),
              ),
              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
