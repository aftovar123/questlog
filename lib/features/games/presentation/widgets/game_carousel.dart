import 'package:flutter/material.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/presentation/widgets/game_grid_item.dart';

/// A horizontally-scrolling row of games with Letterboxd-style edge arrows,
/// instead of a full-viewport grid — keeps the catalog contained rather than
/// filling the whole screen.
class GameCarousel extends StatefulWidget {
  const GameCarousel({required this.games, super.key});

  final List<Game> games;

  @override
  State<GameCarousel> createState() => _GameCarouselState();
}

class _GameCarouselState extends State<GameCarousel> {
  final _scrollController = ScrollController();
  static const _cardWidth = 150.0;
  static const _cardSpacing = 16.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    final target = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 4),
            itemCount: widget.games.length,
            separatorBuilder: (context, index) => const SizedBox(width: _cardSpacing),
            itemBuilder: (context, index) => SizedBox(
              width: _cardWidth,
              child: GameGridItem(game: widget.games[index]),
            ),
          ),
          Positioned(left: 0, child: _CarouselArrow(icon: Icons.chevron_left_rounded, onTap: () => _scrollBy(-(_cardWidth + _cardSpacing) * 3))),
          Positioned(right: 0, child: _CarouselArrow(icon: Icons.chevron_right_rounded, onTap: () => _scrollBy((_cardWidth + _cardSpacing) * 3))),
        ],
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 26, color: scheme.onSurface),
        ),
      ),
    );
  }
}
