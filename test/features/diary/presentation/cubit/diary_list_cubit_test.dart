import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_list_cubit.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_list_state.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';

class _MockGetAllDiaryEntries extends Mock implements GetAllDiaryEntries {}

class _MockGetGameDetail extends Mock implements GetGameDetail {}

void main() {
  late _MockGetAllDiaryEntries getAllDiaryEntries;
  late _MockGetGameDetail getGameDetail;

  final entry1 = DiaryEntry(gameId: 1, status: PlayStatus.playing, updatedAt: DateTime(2026, 1, 2));
  final entry2 = DiaryEntry(gameId: 2, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 1));
  const game1 = Game(id: 1, name: 'Game 1', imageUrl: null, rating: 4.5);

  setUp(() {
    getAllDiaryEntries = _MockGetAllDiaryEntries();
    getGameDetail = _MockGetGameDetail();
  });

  blocTest<DiaryListCubit, DiaryListState>(
    'emits DiaryListEmpty when there are no saved entries',
    setUp: () {
      when(() => getAllDiaryEntries()).thenAnswer((_) async => const Ok([]));
    },
    build: () => DiaryListCubit(getAllDiaryEntries, getGameDetail),
    // Not [Loading, Empty]: the constructor's own emit(DiaryListLoading()) is
    // a no-op — it equals the state the Cubit already started in, and Bloc
    // skips emitting a state that's == the current one.
    expect: () => [const DiaryListEmpty()],
  );

  blocTest<DiaryListCubit, DiaryListState>(
    'joins each entry with its enriched game',
    setUp: () {
      when(() => getAllDiaryEntries()).thenAnswer((_) async => Ok([entry1, entry2]));
      when(() => getGameDetail(1)).thenAnswer((_) async => const Ok(game1));
      when(() => getGameDetail(2)).thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: () => DiaryListCubit(getAllDiaryEntries, getGameDetail),
    expect: () => [
      isA<DiaryListLoaded>().having(
        (s) => s.items,
        'items',
        [(entry: entry1, game: game1), (entry: entry2, game: null)],
      ),
    ],
  );

  blocTest<DiaryListCubit, DiaryListState>(
    'emits DiaryListFailed when reading the diary fails',
    setUp: () {
      when(() => getAllDiaryEntries()).thenAnswer((_) async => const Err(StorageFailure()));
    },
    build: () => DiaryListCubit(getAllDiaryEntries, getGameDetail),
    expect: () => [isA<DiaryListFailed>()],
  );
}
