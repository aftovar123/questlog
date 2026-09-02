import 'package:equatable/equatable.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

sealed class GameDetailState extends Equatable {
  const GameDetailState();

  /// The best data available right now — the game passed in via navigation
  /// while [GameDetailLoading], or the full `/games/{id}` payload once it
  /// lands (or the same navigation data again, if that call failed).
  Game get game;

  @override
  List<Object?> get props => [game];
}

final class GameDetailLoading extends GameDetailState {
  const GameDetailLoading(this.game);
  @override
  final Game game;
}

final class GameDetailLoaded extends GameDetailState {
  const GameDetailLoaded(this.game);
  @override
  final Game game;
}
