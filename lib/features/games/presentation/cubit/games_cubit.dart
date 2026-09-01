import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/usecases/get_games.dart';
import 'package:questlog/features/games/presentation/cubit/games_state.dart';

class GamesCubit extends Cubit<GamesState> {
  GamesCubit(this._getGames) : super(const GamesInitial());
  final GetGames _getGames;

  Future<void> loadGames({String? search}) async {
    emit(const GamesLoading());
    final result = await _getGames(search: search);
    switch (result) {
      case Ok(:final value):
        emit(value.isEmpty ? const GamesEmpty() : GamesLoaded(value));
      case Err(:final failure):
        emit(GamesFailed(failure.message));
    }
  }
}
