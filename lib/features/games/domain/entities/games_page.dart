import 'package:equatable/equatable.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

/// One page of results plus whether the next page is worth requesting —
/// keeps the "how do we know there's more" decision in the data layer,
/// so the Cubit never has to know RAWG's page size.
class GamesPage extends Equatable {
  const GamesPage({required this.games, required this.hasMore});

  final List<Game> games;
  final bool hasMore;

  @override
  List<Object?> get props => [games, hasMore];
}
