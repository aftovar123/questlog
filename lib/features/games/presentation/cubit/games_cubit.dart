import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/usecases/get_games.dart';
import 'package:questlog/features/games/presentation/cubit/games_state.dart';

class GamesCubit extends Cubit<GamesState> {
  GamesCubit(this._getGames) : super(const GamesInitial());
  final GetGames _getGames;

  // "Restartable" by hand: every call bumps this, and a response only gets
  // applied if it's still the most recent one in flight. Fixes exactly the
  // "user taps three times while a request is in progress" scenario — a
  // slow first response can no longer land after a faster, newer one.
  int _requestId = 0;
  String? _search;
  String? _genre;
  int _page = 1;

  Future<void> loadGames({String? search, String? genre}) async {
    _search = search;
    _genre = genre;
    _page = 1;
    final requestId = ++_requestId;

    emit(const GamesLoading());
    final result = await _getGames(page: _page, search: _search, genre: _genre);
    if (requestId != _requestId) return;

    switch (result) {
      case Ok(:final value):
        emit(
          value.games.isEmpty
              ? const GamesEmpty()
              : GamesLoaded(value.games, hasMore: value.hasMore),
        );
      case Err(:final failure):
        emit(GamesFailed(failure.message));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! GamesLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }

    final requestId = ++_requestId;
    emit(current.copyWith(isLoadingMore: true));

    final nextPage = _page + 1;
    final result = await _getGames(page: nextPage, search: _search, genre: _genre);
    if (requestId != _requestId) return;

    switch (result) {
      case Ok(:final value):
        _page = nextPage;
        emit(GamesLoaded([...current.games, ...value.games], hasMore: value.hasMore));
      case Err():
        // Keep the games already on screen — losing them over a failed
        // "load more" would be worse than just stopping the spinner.
        emit(current.copyWith(isLoadingMore: false));
    }
  }
}
