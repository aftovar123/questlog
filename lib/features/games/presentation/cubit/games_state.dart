import 'package:equatable/equatable.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

sealed class GamesState extends Equatable {
  const GamesState();

  @override
  List<Object?> get props => [];
}

final class GamesInitial extends GamesState {
  const GamesInitial();
}

final class GamesLoading extends GamesState {
  const GamesLoading();
}

final class GamesEmpty extends GamesState {
  const GamesEmpty();
}

final class GamesLoaded extends GamesState {
  const GamesLoaded(this.games);
  final List<Game> games;

  @override
  List<Object?> get props => [games];
}

final class GamesFailed extends GamesState {
  const GamesFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
