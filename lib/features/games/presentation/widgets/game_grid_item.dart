import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:questlog/app/theme.dart';
import 'package:questlog/core/widgets/fading_network_image.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

class GameGridItem extends StatelessWidget {
  const GameGridItem({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/games/${game.id}', extra: game),
        child: Stack(
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
                    stops: const [0.5, 1.0],
                    colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.85)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _RatingChip(rating: game.rating),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                game.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final color = RatingColors.forRating(rating);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 13, color: color),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
