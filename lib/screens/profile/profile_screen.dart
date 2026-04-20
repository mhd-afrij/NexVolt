import 'package:flutter/material.dart';

import '../../core/services/firestore_service.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _homeCityController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _homeCityController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    await widget.repository.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      homeCity: _homeCityController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: widget.repository.watchProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data ?? const <String, dynamic>{};
        if (!_initialized && profile.isNotEmpty) {
          _nameController.text = profile['name'] as String? ?? '';
          _emailController.text = profile['email'] as String? ?? '';
          _homeCityController.text = profile['homeCity'] as String? ?? '';
          _initialized = true;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            Text(
              'Profile',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _homeCityController,
                      decoration: const InputDecoration(labelText: 'Home City'),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _saveProfile,
                        child: Text(_saving ? 'Saving...' : 'Save Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favorite Charging Stations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Navigate your charging activity via sub-tabs.'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                FavoritesScreen(repository: widget.repository),
                          ),
                        );
                      },
                      icon: const Icon(Icons.subdirectory_arrow_right),
                      label: const Text('Open Activity Sub-Tabs'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
