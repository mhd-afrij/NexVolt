import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../widgets/account_header_card.dart';
import '../widgets/account_widgets.dart';
import '../widgets/shared_widgets.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import 'help_support_screen.dart';
import 'my_vehicles_screen.dart';
import 'notifications_screen.dart';
import 'app_settings_screen.dart';
import '../../presentation/screens/qr_scanner_screen.dart';

/// Main Account dashboard screen shown inside the bottom navigation shell.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccountData();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AccountProvider>().loadAccountData();
  }

  /// Opens the QR scanner screen
  void _openQrScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Nexvolt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AccountProvider>().logout();
      // Navigate to login after logout — uncomment and update route:
      // Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan QR',
            onPressed: _openQrScanner,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
              if (provider.unreadNotificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: cs.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: provider.isLoading && provider.userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                children: [
                  AccountHeaderCard(
                    profile: provider.userProfile,
                    onEditTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                    onImageTap: () => provider.pickAndUploadProfileImage(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        ProfileStatCard(
                          icon: Icons.electric_car_rounded,
                          value: '${provider.vehicles.length}',
                          label: 'Vehicles',
                        ),
                        ProfileStatCard(
                          icon: Icons.favorite_rounded,
                          value: '${provider.favoriteStations.length}',
                          label: 'Favorites',
                          iconColor: Colors.redAccent,
                        ),
                        ProfileStatCard(
                          icon: Icons.notifications_rounded,
                          value: '${provider.unreadNotificationCount}',
                          label: 'Unread',
                          iconColor: cs.tertiary,
                        ),
                        ProfileStatCard(
                          icon: Icons.bolt_rounded,
                          value: '${provider.chargingActivities.length}',
                          label: 'Sessions',
                          iconColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  // ── Error banner ─────────────────────────────
                  if (provider.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                              provider.errorMessage!,
                              style: TextStyle(color: cs.onErrorContainer),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: cs.onErrorContainer,
                            ),
                            onPressed: provider.clearError,
                          ),
                        ],
                      ),
                    ),

                  // ── Menu: My Account ─────────────────────────
                  const SectionTitle(title: 'My Account'),
                  _MenuCard(
                    children: [
                      AccountMenuTile(
                        icon: Icons.electric_car_rounded,
                        title: 'My Vehicles',
                        subtitle: '${provider.vehicles.length} registered',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyVehiclesScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Menu: Preferences ────────────────────────
                  const SectionTitle(title: 'Preferences'),
                  _MenuCard(
                    children: [
                      AccountMenuTile(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                        trailing: provider.unreadNotificationCount > 0
                            ? _badge(
                                context,
                                provider.unreadNotificationCount.toString(),
                              )
                            : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                      ),
                      _divider(),
                      AccountMenuTile(
                        icon: Icons.favorite_rounded,
                        title: 'Favourite Stations',
                        iconColor: Colors.redAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FavoritesScreen(),
                          ),
                        ),
                      ),
                      _divider(),
                      AccountMenuTile(
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppSettingsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Menu: Support ────────────────────────────
                  const SectionTitle(title: 'Support'),
                  _MenuCard(
                    children: [
                      AccountMenuTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Logout ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: Icon(Icons.logout_rounded, color: cs.error),
                      label: Text('Log Out', style: TextStyle(color: cs.error)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.error.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56);

  Widget _badge(BuildContext context, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Helpers — shared inside this file only

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
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(children: children),
    );
  }
}
