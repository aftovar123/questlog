import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_list_state.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';

/// Composes two features at the presentation layer instead of coupling their
/// domains: `diary` only knows play state, `games` only knows catalog data.
/// This cubit is the one place that joins a saved entry to the game it
/// points to, fetching each game's current details in parallel.
class DiaryListCubit extends Cubit<DiaryListState> {
  DiaryListCubit(this._getAllDiaryEntries, this._getGameDetail) : super(const DiaryListLoading()) {
    load();
  }

  final GetAllDiaryEntries _getAllDiaryEntries;
  final GetGameDetail _getGameDetail;

  Future<void> load() async {
    emit(const DiaryListLoading());
    final result = await _getAllDiaryEntries();
    switch (result) {
      case Ok(:final value):
        if (value.isEmpty) {
          emit(const DiaryListEmpty());
          return;
        }
        final gameResults = await Future.wait(value.map((entry) => _getGameDetail(entry.gameId)));
        final items = [
          for (var i = 0; i < value.length; i++)
            (entry: value[i], game: switch (gameResults[i]) { Ok<Game>(:final value) => value, Err() => null }),
        ];
        emit(DiaryListLoaded(items));
      case Err(:final failure):
        emit(DiaryListFailed(failure.message));
    }
  }
}
