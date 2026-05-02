import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _isSignUp = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      if (_isSignUp) {
        await _doSignUp();
      } else {
        await _doSignIn();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMsg = _friendly(e.code);
      });
    } catch (_) {
      setState(() {
        _errorMsg = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _doSignIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );
  }

  Future<void> _doSignUp() async {
    final email = _emailCtrl.text.trim();

    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: _passCtrl.text.trim(),
    );

    final user = cred.user;

    if (user == null) {
      throw Exception('Signup failed. User not created.');
    }

    final profile = UserProfileModel(
      uid: user.uid,
      fullName: 'Nexvolt User',
      email: user.email ?? email,
      phone: '',
      profileImageUrl: '',
      language: 'en',
      themeMode: 'system',
      membershipType: 'standard',
      notificationsEnabled: true,
      autoReloadEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await context.read<AccountProvider>().updateProfile(profile);
  }

  String _friendly(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Error ($code). Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        size: 48,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Nexvolt',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp ? 'Create your account' : 'Welcome back',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 44),
                if (_errorMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: cs.onErrorContainer,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMsg!,
                            style: TextStyle(
                              color: cs.onErrorContainer,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: _dec(
                    context,
                    'Email Address',
                    Icons.email_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }

                    final ok = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                        .hasMatch(v.trim());

                    return ok ? null : 'Enter a valid email address';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  autofillHints: _isSignUp
                      ? const [AutofillHints.newPassword]
                      : const [AutofillHints.password],
                  decoration: _dec(
                    context,
                    'Password',
                    Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Password is required';
                    }

                    if (_isSignUp && v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isSignUp ? 'Create Account' : 'Log In',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp
                          ? 'Already have an account?  '
                          : "Don't have an account?  ",
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _errorMsg = null;
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        _isSignUp ? 'Log In' : 'Sign Up',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
    );
  }
}