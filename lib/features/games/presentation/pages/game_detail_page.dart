import 'package:flutter/material.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(game.name)),
      body: ListView(
        children: [
          if (game.imageUrl != null)
            Image.network(
              game.imageUrl!,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(game.rating.toStringAsFixed(1)),
                  ],
                ),
                if (game.releaseDate case final releaseDate?) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lanzamiento: ${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
