import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/usecases/compute_diary_stats.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';
import 'package:questlog/features/diary/presentation/cubit/stats_state.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';

/// Same composition as `DiaryListCubit`: `diary` owns the entries, `games`
/// owns what each one means (name, genres), joined here at the presentation
/// layer. Every number `computeDiaryStats` produces comes from whatever is
/// actually in Hive right now — there's no placeholder path.
class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this._getAllDiaryEntries, this._getGameDetail) : super(const StatsLoading()) {
    load();
  }

  final GetAllDiaryEntries _getAllDiaryEntries;
  final GetGameDetail _getGameDetail;

  int _requestId = 0;

  Future<void> load() async {
    final requestId = ++_requestId;
    emit(const StatsLoading());
    final result = await _getAllDiaryEntries();
    if (requestId != _requestId) return;

    switch (result) {
      case Ok(:final value):
        if (value.isEmpty) {
          emit(const StatsEmpty());
          return;
        }
        final gameResults = await Future.wait(value.map((entry) => _getGameDetail(entry.gameId)));
        if (requestId != _requestId) return;

        final gamesById = <int, Game>{
          for (var i = 0; i < value.length; i++)
            if (gameResults[i] case Ok<Game>(:final value)) value.id: value,
        };
        emit(StatsLoaded(computeDiaryStats(value, gamesById)));
      case Err(:final failure):
        emit(StatsFailed(failure.message));
    }
  }
}
