import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/app/injection.dart';
import 'package:questlog/app/theme.dart';
import 'package:questlog/core/widgets/fading_network_image.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';
import 'package:questlog/features/games/presentation/cubit/game_detail_cubit.dart';
import 'package:questlog/features/games/presentation/cubit/game_detail_state.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameDetailCubit(getIt<GetGameDetail>(), game),
      child: const _GameDetailView(),
    );
  }
}

class _GameDetailView extends StatelessWidget {
  const _GameDetailView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<GameDetailCubit>().state;
    final game = state.game;
    final ratingColor = RatingColors.forRating(game.rating);
    final isEnriching = state is GameDetailLoading;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: scheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'game-cover-${game.id}',
                    child: FadingNetworkImage(imageUrl: game.imageUrl, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.4, 1.0],
                          colors: [Colors.black.withValues(alpha: 0), scheme.surface],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isEnriching)
            SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2, color: scheme.primary),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ratingColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: ratingColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: ratingColor),
                            const SizedBox(width: 4),
                            Text(
                              game.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ratingColor),
                            ),
                          ],
                        ),
                      ),
                      if (game.releaseDate case final releaseDate?) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.event_rounded, size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                  if (game.genres.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _TagSection(label: l10n.genresLabel, tags: game.genres),
                  ],
                  if (game.platforms.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _TagSection(label: l10n.platformsLabel, tags: game.platforms),
                  ],
                  if (game.description case final description?) ...[
                    const SizedBox(height: 24),
                    Text(l10n.aboutLabel, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _ExpandableDescription(text: description),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  const _TagSection({required this.label, required this.tags});

  final String label;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in tags)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(tag, style: Theme.of(context).textTheme.bodyMedium),
              ),
          ],
        ),
      ],
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({required this.text});

  final String text;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topLeft,
          child: Text(
            widget.text,
            maxLines: _expanded ? null : 4,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 36)),
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? l10n.readLessLabel : l10n.readMoreLabel,
            style: TextStyle(color: scheme.primary),
          ),
        ),
      ],
    );
  }
}
