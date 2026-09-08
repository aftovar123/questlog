import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/domain/usecases/delete_diary_entry.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_list_cubit.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_list_state.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';

class _MockGetAllDiaryEntries extends Mock implements GetAllDiaryEntries {}

class _MockGetGameDetail extends Mock implements GetGameDetail {}

class _MockDeleteDiaryEntry extends Mock implements DeleteDiaryEntry {}

void main() {
  late _MockGetAllDiaryEntries getAllDiaryEntries;
  late _MockGetGameDetail getGameDetail;
  late _MockDeleteDiaryEntry deleteDiaryEntry;

  final entry1 = DiaryEntry(gameId: 1, status: PlayStatus.playing, updatedAt: DateTime(2026, 1, 2));
  final entry2 = DiaryEntry(gameId: 2, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 1));
  const game1 = Game(id: 1, name: 'Game 1', imageUrl: null, rating: 4.5);
  const game2 = Game(id: 2, name: 'Game 2', imageUrl: null, rating: 3.5);

  setUp(() {
    getAllDiaryEntries = _MockGetAllDiaryEntries();
    getGameDetail = _MockGetGameDetail();
    deleteDiaryEntry = _MockDeleteDiaryEntry();
  });

  blocTest<DiaryListCubit, DiaryListState>(
    'emits DiaryListEmpty when there are no saved entries',
    setUp: () {
      when(() => getAllDiaryEntries()).thenAnswer((_) async => const Ok([]));
    },
    build: () => DiaryListCubit(getAllDiaryEntries, getGameDetail, deleteDiaryEntry),
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
    build: () => DiaryListCubit(getAllDiaryEntries, getGameDetail, deleteDiaryEntry),
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
    build: () => DiaryListCubit(getAllDiaryEntries, getGameDetail, deleteDiaryEntry),
    expect: () => [isA<DiaryListFailed>()],
  );

  test('ignores a stale load() response that resolves after a newer one', () async {
    final firstRequest = Completer<Result<List<DiaryEntry>>>();
    var callCount = 0;
    when(() => getAllDiaryEntries()).thenAnswer((_) {
      callCount++;
      return callCount == 1 ? firstRequest.future : Future.value(const Ok(<DiaryEntry>[]));
    });

    final cubit = DiaryListCubit(getAllDiaryEntries, getGameDetail, deleteDiaryEntry); // triggers the first (stale) call
    await cubit.load(); // supersedes the first before it resolves

    expect(cubit.state, const DiaryListEmpty());

    firstRequest.complete(Ok([entry1])); // the stale response arrives late
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, const DiaryListEmpty()); // unchanged — the stale result was ignored
    await cubit.close();
  });

  blocTest<DiaryListCubit, DiaryListState>(
    'delete removes just that entry and keeps the rest of the list',
    setUp: () {
      when(() => getAllDiaryEntries()).thenAnswer((_) async => Ok([entry1, entry2]));
      when(() => getGameDetail(1)).thenAnswer((_) async => const Ok(game1));
      when(() => getGameDetail(2)).thenAnswer((_) async => const Ok(game2));
      when(() => deleteDiaryEntry(1)).thenAnswer((_) async => const Ok(Unit.instance));
    },
    build: () => DiaryListCubit(getAllDiaryEntries, getGameDetail, deleteDiaryEntry),
    act: (cubit) => cubit.delete(1),
    skip: 1, // the initial DiaryListLoaded([entry1, entry2])
    expect: () => [
      isA<DiaryListLoaded>().having((s) => s.items, 'items', [(entry: entry2, game: game2)]),
    ],
  );

  blocTest<DiaryListCubit, DiaryListState>(
    'delete emits DiaryListEmpty when it removes the last entry',
    setUp: () {
      when(() => getAllDiaryEntries()).thenAnswer((_) async => Ok([entry1]));
      when(() => getGameDetail(1)).thenAnswer((_) async => const Ok(game1));
      when(() => deleteDiaryEntry(1)).thenAnswer((_) async => const Ok(Unit.instance));
    },
    build: () => DiaryListCubit(getAllDiaryEntries, getGameDetail, deleteDiaryEntry),
    act: (cubit) => cubit.delete(1),
    skip: 1,
    expect: () => [const DiaryListEmpty()],
  );

  test('delete leaves the list untouched and returns false when it fails', () async {
    when(() => getAllDiaryEntries()).thenAnswer((_) async => Ok([entry1]));
    when(() => getGameDetail(1)).thenAnswer((_) async => const Ok(game1));
    when(() => deleteDiaryEntry(1)).thenAnswer((_) async => const Err(StorageFailure()));

    final cubit = DiaryListCubit(getAllDiaryEntries, getGameDetail, deleteDiaryEntry);
    await Future<void>.delayed(Duration.zero);

    final succeeded = await cubit.delete(1);

    expect(succeeded, isFalse);
    expect(
      cubit.state,
      isA<DiaryListLoaded>().having((s) => s.items, 'items', [(entry: entry1, game: game1)]),
    );
    await cubit.close();
  });
}
