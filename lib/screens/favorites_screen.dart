import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/favorite_station_model.dart';
import '../providers/account_provider.dart';
import '../widgets/shared_widgets.dart';

/// Lists the user's saved favourite charging stations.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadFavorites();
    });
  }

  Future<void> _confirmRemove(
      BuildContext context, FavoriteStationModel fav) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Favourite'),
        content: Text('Remove "${fav.stationName}" from favourites?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AccountProvider>().removeFavorite(fav.favoriteId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final favourites = provider.favoriteStations;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Favourite Stations')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<AccountProvider>().loadFavorites(),
              child: favourites.isEmpty
                  ? const AccountEmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No Favourites Yet',
                      subtitle:
                          'Stations you favourite will appear here for quick access.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: favourites.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72, endIndent: 16),
                      itemBuilder: (_, i) {
                        final fav = favourites[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.favorite_rounded,
                                color: Colors.redAccent, size: 22),
                          ),
                          title: Text(
                            fav.stationName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Saved ${DateFormat('dd MMM yyyy').format(fav.createdAt)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.directions_rounded,
                                    color: cs.primary),
                                tooltip: 'View Station',
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Station detail navigation — connect to station module'),
                                  ));
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded,
                                    color: cs.error),
                                tooltip: 'Remove',
                                onPressed: () =>
                                    _confirmRemove(context, fav),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
