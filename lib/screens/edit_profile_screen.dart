import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_profile_model.dart';
import '../providers/account_provider.dart';

/// Screen for editing full name, email, phone, and preferred language.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  String _selectedLanguage = 'en';
  bool _saving = false;

  static const _languages = {
    'en': 'English',
    'si': 'Sinhala (සිංහල)',
    'ta': 'Tamil (தமிழ்)',
  };

  @override
  void initState() {
    super.initState();
    final profile =
        context.read<AccountProvider>().userProfile ?? UserProfileModel.empty();
    _nameCtrl = TextEditingController(text: profile.fullName);
    final authEmail = FirebaseAuth.instance.currentUser?.email ?? '';
_emailCtrl = TextEditingController(
  text: profile.email.trim().isNotEmpty ? profile.email : authEmail,
);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _selectedLanguage = profile.language;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final provider = context.read<AccountProvider>();
    final existing =
        provider.userProfile ?? UserProfileModel.empty();

    final updated = existing.copyWith(
      fullName: _nameCtrl.text.trim(),
      email: FirebaseAuth.instance.currentUser?.email ?? _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      language: _selectedLanguage,
      updatedAt: DateTime.now(),
    );

    final success = await provider.updateProfile(updated);
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(provider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Profile picture ──
              Center(
                child: Consumer<AccountProvider>(
                  builder: (_, provider, __) {
                    return GestureDetector(
                      onTap: provider.isLoading
                          ? null
                          : () => provider.pickAndUploadProfileImage(),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: cs.primaryContainer,
                            backgroundImage: provider.userProfile
                                        ?.profileImageUrl.isNotEmpty ==
                                    true
                                ? NetworkImage(
                                    provider.userProfile!.profileImageUrl)
                                : null,
                            child: provider.userProfile?.profileImageUrl
                                        .isEmpty ??
                                    true
                                ? Icon(Icons.person_rounded,
                                    size: 48, color: cs.onPrimaryContainer)
                                : null,
                          ),
                          if (provider.isLoading)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: cs.surface, width: 2),
                              ),
                              child: Icon(Icons.camera_alt_rounded,
                                  size: 16, color: cs.onPrimary),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // ── Full Name ──
              TextFormField(
                controller: _nameCtrl,
                decoration: _inputDec('Full Name', Icons.person_outline),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  if (v.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Email ──
              TextFormField(
                controller: _emailCtrl,
                decoration: _inputDec('Email Address', Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex =
                      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Phone ──
              TextFormField(
                controller: _phoneCtrl,
                decoration: _inputDec('Phone Number', Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  // Sri Lanka: +94 or 07x format
                  final phoneRegex = RegExp(r'^(\+94|0)[0-9]{9}$');
                  if (!phoneRegex.hasMatch(v.trim().replaceAll(' ', ''))) {
                    return 'Enter a valid Sri Lankan phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Language ──
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration:
                    _inputDec('Preferred Language', Icons.language_outlined),
                items: _languages.entries
                    .map((e) => DropdownMenuItem(
                        value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedLanguage = v);
                },
              ),
              const SizedBox(height: 32),

              // ── Save button ──
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
    );
  }
}
