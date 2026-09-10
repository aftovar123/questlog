import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';
import 'package:questlog/features/diary/presentation/cubit/stats_cubit.dart';
import 'package:questlog/features/diary/presentation/cubit/stats_state.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';

class _MockGetAllDiaryEntries extends Mock implements GetAllDiaryEntries {}

class _MockGetGameDetail extends Mock implements GetGameDetail {}

void main() {
  late _MockGetAllDiaryEntries getAllDiaryEntries;
  late _MockGetGameDetail getGameDetail;

  final entry1 = DiaryEntry(
    gameId: 1,
    status: PlayStatus.completed,
    updatedAt: DateTime(2026, 1, 1),
    rating: 5,
  );
  final entry2 = DiaryEntry(gameId: 2, status: PlayStatus.backlog, updatedAt: DateTime(2026, 1, 2));
  const game1 = Game(id: 1, name: 'Game 1', imageUrl: null, rating: 4.5, genres: ['RPG']);

  setUp(() {
    getAllDiaryEntries = _MockGetAllDiaryEntries();
    getGameDetail = _MockGetGameDetail();
  });

  blocTest<StatsCubit, StatsState>(
    'emits StatsEmpty when the diary has no entries',
    setUp: () {
      when(() => getAllDiaryEntries()).thenAnswer((_) async => const Ok([]));
    },
    build: () => StatsCubit(getAllDiaryEntries, getGameDetail),
    expect: () => [const StatsEmpty()],
  );

  blocTest<StatsCubit, StatsState>(
    'emits StatsLoaded with stats computed from the real diary entries',
    setUp: () {
      when(() => getAllDiaryEntries()).thenAnswer((_) async => Ok([entry1, entry2]));
      when(() => getGameDetail(1)).thenAnswer((_) async => const Ok(game1));
      when(() => getGameDetail(2)).thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: () => StatsCubit(getAllDiaryEntries, getGameDetail),
    expect: () => [
      isA<StatsLoaded>()
          .having((s) => s.stats.totalTracked, 'totalTracked', 2)
          .having((s) => s.stats.completedCount, 'completedCount', 1)
          .having((s) => s.stats.averageRating, 'averageRating', 5.0)
          .having((s) => s.stats.topGenre, 'topGenre', 'RPG'),
    ],
  );

  blocTest<StatsCubit, StatsState>(
    'emits StatsFailed when reading the diary itself fails',
    setUp: () {
      when(() => getAllDiaryEntries()).thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: () => StatsCubit(getAllDiaryEntries, getGameDetail),
    expect: () => [isA<StatsFailed>()],
  );

  blocTest<StatsCubit, StatsState>(
    'load() is restartable: a stale first call cannot land after a newer one',
    setUp: () {
      var callCount = 0;
      when(() => getAllDiaryEntries()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return const Ok([]);
        }
        return Ok([entry1]);
      });
      when(() => getGameDetail(1)).thenAnswer((_) async => const Ok(game1));
    },
    build: () => StatsCubit(getAllDiaryEntries, getGameDetail),
    // Not [Loading, Loaded]: act's load() re-emits StatsLoading, but that's
    // == the state the constructor's own load() already put it in, so Bloc
    // skips it — same as DiaryListCubit's equivalent test.
    act: (cubit) => cubit.load(),
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<StatsLoaded>().having((s) => s.stats.totalTracked, 'totalTracked', 1)],
  );
}
