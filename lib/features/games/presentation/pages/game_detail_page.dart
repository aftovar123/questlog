import 'package:flutter/material.dart';
import 'package:questlog/app/theme.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratingColor = RatingColors.forRating(game.rating);

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
                    child: game.imageUrl != null
                        ? Image.network(
                            game.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                ColoredBox(color: scheme.surfaceContainerHighest),
                          )
                        : ColoredBox(color: scheme.surfaceContainerHighest),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
