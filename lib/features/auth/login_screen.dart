import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sync/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon / Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 44,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isThai ? 'MyFinance' : 'MyFinance',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isThai
                      ? 'เข้าสู่ระบบเพื่อ sync ข้อมูลข้ามอุปกรณ์'
                      : 'Sign in to sync data across devices',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 1,
                    ),
                    onPressed: _loading ? null : _signInWithGoogle,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Image.asset(
                            'assets/images/google_logo.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.login, size: 20),
                          ),
                    label: Text(
                      isThai ? 'เข้าสู่ระบบด้วย Google' : 'Sign in with Google',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),

                // Skip button
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: Text(
                    isThai ? 'ข้ามและใช้งาน offline' : 'Continue offline (no sync)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isThai
                      ? 'โหมด offline: ข้อมูลอยู่เฉพาะในอุปกรณ์นี้'
                      : 'Offline mode: data stays on this device only',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
