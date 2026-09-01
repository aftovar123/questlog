import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/app/injection.dart';
import 'package:questlog/features/games/domain/usecases/get_games.dart';
import 'package:questlog/features/games/presentation/cubit/games_cubit.dart';
import 'package:questlog/features/games/presentation/cubit/games_state.dart';
import 'package:questlog/features/games/presentation/widgets/game_grid_item.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

class GamesListPage extends StatefulWidget {
  const GamesListPage({super.key});

  @override
  State<GamesListPage> createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  late final GamesCubit _cubit;
  final _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.gamesListTitle)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (value) => _cubit.loadGames(search: value),
              ),
            ),
            Expanded(
              child: BlocBuilder<GamesCubit, GamesState>(
                builder: (context, state) => switch (state) {
                  GamesInitial() || GamesLoading() =>
                    Center(child: Text(l10n.loadingLabel)),
                  GamesEmpty() => Center(child: Text(l10n.emptyGamesMessage)),
                  GamesFailed(:final message) => _ErrorView(
                    message: message,
                    retryLabel: l10n.retryLabel,
                    onRetry: () =>
                        _cubit.loadGames(search: _searchController.text),
                  ),
                  GamesLoaded(:final games) => GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.7,
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}
