import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_inputs.dart';
import '../../core/widgets/rakshak_logo.dart';
import 'admin_auth_controller.dart';
import 'demo_admin_credentials.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _username = TextEditingController(text: DemoAdminCredentials.username);
  final _password = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await ref
        .read(adminAuthProvider.notifier)
        .signIn(_username.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.go(AppRoutes.adminDashboard);
    } else {
      setState(() => _error = 'Incorrect demo admin credentials.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RakshakLogo(size: 56),
                const SizedBox(height: Spacing.lg),
                Text(
                  'Rakshak Admin',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Demo credentials — username "${DemoAdminCredentials.username}"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                RakshakTextField(
                  label: 'Admin username',
                  controller: _username,
                ),
                const SizedBox(height: Spacing.lg),
                RakshakTextField(
                  label: 'Password',
                  controller: _password,
                  obscureText: true,
                  errorText: _error,
                ),
                const SizedBox(height: Spacing.xl),
                RakshakButton(
                  label: 'Sign in',
                  isLoading: _loading,
                  onPressed: _signIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
