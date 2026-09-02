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
    final textTheme = Theme.of(context).textTheme;
    final ratingColor = RatingColors.forRating(game.rating);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.push('/games/${game.id}', extra: game),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: DecoratedBox(
                decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
                child: Hero(
                  tag: 'game-cover-${game.id}',
                  child: FadingNetworkImage(imageUrl: game.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            game.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 14, color: ratingColor),
              const SizedBox(width: 3),
              Text(
                game.rating.toStringAsFixed(1),
                style: textTheme.bodyMedium?.copyWith(color: ratingColor),
              ),
              if (game.genres.isNotEmpty) ...[
                Text(' · ', style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                Expanded(
                  child: Text(
                    game.genres.first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
