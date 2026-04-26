import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_colors.dart';
import '../core/services/firestore_service.dart';
import '../core/services/firebase_auth_service.dart';
import 'auth_check_screen.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  late AnimationController _controller;
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Widget animatedButton(String text, VoidCallback onTap) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(
          AppColors.primary,
          AppColors.secondary,
          _controller.value,
        );
        return ElevatedButton(
          onPressed: _isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: color,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                  ),
                ),
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuthService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final fullName =
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}'
              .trim();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && fullName.isNotEmpty) {
        await currentUser.updateDisplayName(fullName);
      }

      final repository = AppRepository(useRemoteDb: true);
      await repository.updateProfile(
        name: fullName,
        email: emailController.text.trim(),
        homeCity: '',
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthCheckScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('🔥 Register error: $e');

      final message = _registerErrorMessage(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: AppColors.onErrorContainer),
          ),
          backgroundColor: AppColors.errorContainer,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _registerErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        default:
          return 'Registration failed. Try again.';
      }
    }

    return 'Registration failed. Try again.';
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool? showObscure,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      autocorrect: false,
      enableSuggestions: !obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
        suffixIcon: showObscure != null
            ? IconButton(
                icon: Icon(
                  showObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: onToggle,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.secondaryGradient),
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Text(
              'Create Account',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fill your details to get started',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                controller: firstNameController,
                                hint: 'First Name',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                controller: lastNameController,
                                hint: 'Last Name',
                                icon: Icons.person_outline,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        _buildField(
                          controller: emailController,
                          hint: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        _buildField(
                          controller: passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscure: _obscurePass,
                          showObscure: _obscurePass,
                          onToggle: () =>
                              setState(() => _obscurePass = !_obscurePass),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (v.length < 6) {
                              return 'Minimum 6 characters required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        _buildField(
                          controller: confirmPassController,
                          hint: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          showObscure: _obscureConfirm,
                          onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          validator: (v) {
                            if (v != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: animatedButton(
                            'Create Account',
                            _handleRegister,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
