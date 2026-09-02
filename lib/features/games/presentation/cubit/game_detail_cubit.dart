import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';
import 'package:questlog/features/games/presentation/cubit/game_detail_state.dart';

/// Shows the game passed in via navigation immediately — so the Hero
/// transition and header never wait on the network — then enriches it with
/// the full `/games/{id}` payload (description, genres, platforms).
class GameDetailCubit extends Cubit<GameDetailState> {
  GameDetailCubit(this._getGameDetail, Game initialGame)
    : super(GameDetailLoading(initialGame)) {
    _loadDetail(initialGame);
  }

  final GetGameDetail _getGameDetail;

  Future<void> _loadDetail(Game initialGame) async {
    final result = await _getGameDetail(initialGame.id);
    switch (result) {
      case Ok(:final value):
        emit(GameDetailLoaded(value));
      case Err():
        // The navigation data is already enough to render the page; a
        // failed enrichment call just means no description/genres/platforms.
        emit(GameDetailLoaded(initialGame));
    }
  }
}
