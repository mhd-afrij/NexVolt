import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'English';

  static const _languages = <String>['English', 'Sinhala', 'Tamil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Language')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Choose your preferred app language.'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selected,
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
            ),
            items: _languages
                .map(
                  (language) => DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selected = value);
              }
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
