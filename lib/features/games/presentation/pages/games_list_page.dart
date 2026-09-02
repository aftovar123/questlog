import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/app/injection.dart';
import 'package:questlog/features/games/domain/usecases/get_games.dart';
import 'package:questlog/features/games/presentation/cubit/games_cubit.dart';
import 'package:questlog/features/games/presentation/cubit/games_state.dart';
import 'package:questlog/features/games/presentation/widgets/game_grid_item.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

/// A small curated subset of RAWG genre slugs — enough to make the list
/// filterable without a second endpoint just to populate a chip row.
const _genreOptions = <(String slug, String label)>[
  ('action', 'Action'),
  ('role-playing-games-rpg', 'RPG'),
  ('adventure', 'Adventure'),
  ('shooter', 'Shooter'),
  ('strategy', 'Strategy'),
  ('indie', 'Indie'),
  ('puzzle', 'Puzzle'),
];

class GamesListPage extends StatefulWidget {
  const GamesListPage({super.key});

  @override
  State<GamesListPage> createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  late final GamesCubit _cubit;
  final _searchController = TextEditingController();
  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    _cubit = GamesCubit(getIt<GetGames>())..loadGames();
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    _cubit.loadGames(search: _searchController.text, genre: _selectedGenre);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _BrandMark(),
              const SizedBox(width: 10),
              Text(l10n.gamesListTitle),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (_) => _reload(),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _genreOptions.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ChoiceChip(
                      label: Text(l10n.allGenresLabel),
                      selected: _selectedGenre == null,
                      onSelected: (_) => setState(() {
                        _selectedGenre = null;
                        _reload();
                      }),
                    );
                  }
                  final (slug, label) = _genreOptions[index - 1];
                  return ChoiceChip(
                    label: Text(label),
                    selected: _selectedGenre == slug,
                    onSelected: (_) => setState(() {
                      _selectedGenre = slug;
                      _reload();
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<GamesCubit, GamesState>(
                builder: (context, state) => switch (state) {
                  GamesInitial() || GamesLoading() => _StatusView(
                    icon: Icons.sports_esports_rounded,
                    message: l10n.loadingLabel,
                    spinning: true,
                  ),
                  GamesEmpty() => _StatusView(
                    icon: Icons.search_off_rounded,
                    message: l10n.emptyGamesMessage,
                  ),
                  GamesFailed(:final message) => _ErrorView(
                    message: message,
                    retryLabel: l10n.retryLabel,
                    onRetry: _reload,
                  ),
                  GamesLoaded(:final games) => GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.48,
                        ),
                    itemCount: games.length,
                    itemBuilder: (context, index) =>
                        GameGridItem(game: games[index]),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [scheme.primary, scheme.secondary, scheme.tertiary];
    return SizedBox(
      width: 34,
      height: 16,
      child: Stack(
        children: [
          for (final (index, color) in colors.indexed)
            Positioned(
              left: index * 10.0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.message,
    this.spinning = false,
  });

  final IconData icon;
  final String message;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (spinning)
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(color: scheme.primary, strokeWidth: 3),
            )
          else
            Icon(icon, size: 44, color: scheme.onSurfaceVariant),
          const SizedBox(height: 14),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44, color: scheme.error),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
