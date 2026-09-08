import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/usecases/delete_diary_entry.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_list_state.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';

/// Composes two features at the presentation layer instead of coupling their
/// domains: `diary` only knows play state, `games` only knows catalog data.
/// This cubit is the one place that joins a saved entry to the game it
/// points to, fetching each game's current details in parallel.
class DiaryListCubit extends Cubit<DiaryListState> {
  DiaryListCubit(this._getAllDiaryEntries, this._getGameDetail, this._deleteDiaryEntry)
    : super(const DiaryListLoading()) {
    _ready = load();
  }

  final GetAllDiaryEntries _getAllDiaryEntries;
  final GetGameDetail _getGameDetail;
  final DeleteDiaryEntry _deleteDiaryEntry;

  // Same "restartable" pattern as GamesCubit: load() is reachable a second
  // time via the "Retry" button on DiaryListFailed, so a slow first call
  // must not be allowed to land after a faster, newer one.
  int _requestId = 0;

  // Same reasoning as DiaryCubit's own guard: delete() only makes sense once
  // a list is actually showing, but awaiting the constructor's own load()
  // here means delete() can never race ahead of it.
  late Future<void> _ready;

  Future<void> load() async {
    final requestId = ++_requestId;
    emit(const DiaryListLoading());
    final result = await _getAllDiaryEntries();
    if (requestId != _requestId) return;

    switch (result) {
      case Ok(:final value):
        if (value.isEmpty) {
          emit(const DiaryListEmpty());
          return;
        }
        final gameResults = await Future.wait(value.map((entry) => _getGameDetail(entry.gameId)));
        if (requestId != _requestId) return;

        final items = [
          for (var i = 0; i < value.length; i++)
            (entry: value[i], game: switch (gameResults[i]) { Ok<Game>(:final value) => value, Err() => null }),
        ];
        emit(DiaryListLoaded(items));
      case Err(:final failure):
        emit(DiaryListFailed(failure.message));
    }
  }

  /// Removes one entry and updates the list in place — no full reload, so a
  /// swipe-to-delete doesn't cause every other row's game to be re-fetched.
  /// Returns whether it succeeded, so the UI can decide whether to keep the
  /// swiped-away row gone or restore it.
  Future<bool> delete(int gameId) async {
    await _ready;
    final result = await _deleteDiaryEntry(gameId);
    switch (result) {
      case Ok():
        final current = state;
        if (current is DiaryListLoaded) {
          final remaining = current.items.where((item) => item.entry.gameId != gameId).toList();
          emit(remaining.isEmpty ? const DiaryListEmpty() : DiaryListLoaded(remaining));
        }
        return true;
      case Err():
        return false;
    }
  }
}
