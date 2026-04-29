import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../widgets/shared_widgets.dart';

/// App-level settings: notifications, auto-reload, language, theme, legal.
class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  static const _languages = {
    'en': 'English',
    'si': 'Sinhala (සිංහල)',
    'ta': 'Tamil (தமிழ்)',
  };

  static const _themeModes = ['system', 'light', 'dark'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final profile = provider.userProfile;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Notifications & Preferences ──
          const SectionTitle(title: 'Preferences'),

          SettingsSwitchTile(
            icon: Icons.notifications_rounded,
            title: 'Push Notifications',
            subtitle: 'Receive alerts for sessions and offers',
            value: profile?.notificationsEnabled ?? true,
            onChanged: (v) =>
                context.read<AccountProvider>().toggleNotifications(v),
          ),
          SettingsSwitchTile(
            icon: Icons.autorenew_rounded,
            title: 'Auto Reload',
            subtitle: 'Automatically top up wallet when balance is low',
            value: profile?.autoReloadEnabled ?? false,
            onChanged: (v) =>
                context.read<AccountProvider>().toggleAutoReload(v),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── Language ──
          const SectionTitle(title: 'Language & Display'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonFormField<String>(
              value: profile?.language ?? 'en',
              decoration: InputDecoration(
                labelText: 'App Language',
                prefixIcon: const Icon(Icons.language_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: cs.surfaceContainerLow,
              ),
              items: _languages.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  context.read<AccountProvider>().changeLanguage(v);
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Theme mode segmented control ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THEME',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: _themeModes
                      .map((m) => ButtonSegment(
                            value: m,
                            label: Text(
                                m[0].toUpperCase() + m.substring(1)),
                            icon: Icon(_themeIcon(m)),
                          ))
                      .toList(),
                  selected: {profile?.themeMode ?? 'system'},
                  onSelectionChanged: (sel) {
                    context
                        .read<AccountProvider>()
                        .changeThemeMode(sel.first);
                  },
                ),
              ],
            ),
          ),

          // ── Legal ──
          const SectionTitle(title: 'Legal & About'),
          _MenuCard(
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () {
                  _showPlaceholderSnack(context, 'Privacy Policy');
                },
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Terms & Conditions'),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () {
                  _showPlaceholderSnack(context, 'Terms & Conditions');
                },
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About Nexvolt'),
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  IconData _themeIcon(String mode) {
    switch (mode) {
      case 'light':
        return Icons.light_mode_rounded;
      case 'dark':
        return Icons.dark_mode_rounded;
      default:
        return Icons.brightness_auto_rounded;
    }
  }

  void _showPlaceholderSnack(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title link coming soon')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Nexvolt',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const Text(
          'Nexvolt is Sri Lanka\'s smart EV charging slot booking platform. '
          'Find, book, and manage your charging sessions with ease.',
        ),
      ],
    );
  }
}

/// Internal card wrapper for settings groups.
class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withOpacity(0.3)),
      ),
      child: Column(children: children),
    );
  }
}
