import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:questlog/app/theme.dart';
import 'package:questlog/core/widgets/fading_network_image.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

class GameGridItem extends StatefulWidget {
  const GameGridItem({required this.game, super.key});

  final Game game;

  @override
  State<GameGridItem> createState() => _GameGridItemState();
}

class _GameGridItemState extends State<GameGridItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ratingColor = RatingColors.forRating(widget.game.rating);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          // The border above is the only hover feedback we want — Material's
          // own hover/highlight tint is switched off so the two never fight.
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.push('/games/${widget.game.id}', extra: widget.game),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
                    child: Hero(
                      tag: 'game-cover-${widget.game.id}',
                      child: FadingNetworkImage(imageUrl: widget.game.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.game.name,
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
                    widget.game.rating.toStringAsFixed(1),
                    style: textTheme.bodyMedium?.copyWith(color: ratingColor),
                  ),
                  if (widget.game.genres.isNotEmpty) ...[
                    Text(' · ', style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    Expanded(
                      child: Text(
                        widget.game.genres.first,
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
        ),
      ),
    );
  }
}
