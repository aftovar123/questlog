import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/clock.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';
import 'package:questlog/features/diary/domain/usecases/get_diary_entry.dart';
import 'package:questlog/features/diary/domain/usecases/save_diary_entry.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_state.dart';

class _MockDiaryRepository extends Mock implements DiaryRepository {}

/// A clock that always answers with whatever instant the test sets — the
/// point of injecting a [Clock] instead of calling `DateTime.now()`
/// directly: a test can pin "now" instead of asserting loosely around
/// whatever the real clock happened to read when it ran.
class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;
}

void main() {
  late _MockDiaryRepository repository;
  late GetDiaryEntry getDiaryEntry;
  late SaveDiaryEntry saveDiaryEntry;
  final fixedNow = DateTime(2026, 3, 15, 9, 30);
  late _FixedClock clock;

  setUpAll(() {
    registerFallbackValue(
      DiaryEntry(gameId: 0, status: PlayStatus.backlog, updatedAt: DateTime(2026, 1, 1)),
    );
  });

  setUp(() {
    repository = _MockDiaryRepository();
    getDiaryEntry = GetDiaryEntry(repository);
    saveDiaryEntry = SaveDiaryEntry(repository);
    clock = _FixedClock(fixedNow);
  });

  blocTest<DiaryCubit, DiaryState>(
    'starts empty when the game has no diary entry yet',
    setUp: () {
      when(() => repository.getEntry(1)).thenAnswer((_) async => const Ok(null));
    },
    build: () => DiaryCubit(getDiaryEntry, saveDiaryEntry, 1, clock),
    expect: () => [const DiaryLoaded(null)],
  );

  blocTest<DiaryCubit, DiaryState>(
    'loads the existing entry for the game',
    setUp: () {
      when(() => repository.getEntry(1)).thenAnswer(
        (_) async => Ok(DiaryEntry(gameId: 1, status: PlayStatus.playing, updatedAt: DateTime(2026, 1, 1))),
      );
    },
    build: () => DiaryCubit(getDiaryEntry, saveDiaryEntry, 1, clock),
    expect: () => [isA<DiaryLoaded>().having((s) => s.entry?.status, 'status', PlayStatus.playing)],
  );

  blocTest<DiaryCubit, DiaryState>(
    'updateStatus creates an entry from scratch and saves it',
    setUp: () {
      when(() => repository.getEntry(1)).thenAnswer((_) async => const Ok(null));
      when(() => repository.saveEntry(any())).thenAnswer((_) async => const Ok(Unit.instance));
    },
    build: () => DiaryCubit(getDiaryEntry, saveDiaryEntry, 1, clock),
    act: (cubit) => cubit.updateStatus(PlayStatus.playing),
    skip: 1, // the initial DiaryLoaded(null) from the constructor's _load()
    expect: () => [
      isA<DiaryLoaded>().having((s) => s.isSaving, 'isSaving', true),
      isA<DiaryLoaded>()
          .having((s) => s.entry?.status, 'status', PlayStatus.playing)
          .having((s) => s.isSaving, 'isSaving', false),
    ],
  );

  blocTest<DiaryCubit, DiaryState>(
    'keeps the previous entry and surfaces the message when saving fails',
    setUp: () {
      when(() => repository.getEntry(1)).thenAnswer((_) async => const Ok(null));
      when(() => repository.saveEntry(any())).thenAnswer((_) async => const Err(StorageFailure()));
    },
    build: () => DiaryCubit(getDiaryEntry, saveDiaryEntry, 1, clock),
    act: (cubit) => cubit.saveReview(rating: 5, note: ''),
    skip: 1,
    expect: () => [
      isA<DiaryLoaded>().having((s) => s.isSaving, 'isSaving', true),
      isA<DiaryLoaded>()
          .having((s) => s.entry, 'entry', isNull)
          .having((s) => s.error, 'error', isNotNull),
    ],
  );

  blocTest<DiaryCubit, DiaryState>(
    'saveReview saves the rating and the note together, in one save',
    setUp: () {
      when(() => repository.getEntry(1)).thenAnswer((_) async => const Ok(null));
      when(() => repository.saveEntry(any())).thenAnswer((_) async => const Ok(Unit.instance));
    },
    build: () => DiaryCubit(getDiaryEntry, saveDiaryEntry, 1, clock),
    act: (cubit) => cubit.saveReview(rating: 4, note: '  Great combat  '),
    skip: 1,
    expect: () => [
      isA<DiaryLoaded>().having((s) => s.isSaving, 'isSaving', true),
      isA<DiaryLoaded>()
          .having((s) => s.entry?.rating, 'rating', 4)
          .having((s) => s.entry?.note, 'note', 'Great combat')
          .having((s) => s.isSaving, 'isSaving', false),
    ],
  );

  blocTest<DiaryCubit, DiaryState>(
    'stamps updatedAt with whatever the injected clock reads, not the real one',
    setUp: () {
      when(() => repository.getEntry(1)).thenAnswer((_) async => const Ok(null));
      when(() => repository.saveEntry(any())).thenAnswer((_) async => const Ok(Unit.instance));
    },
    build: () => DiaryCubit(getDiaryEntry, saveDiaryEntry, 1, clock),
    act: (cubit) => cubit.updateStatus(PlayStatus.completed),
    skip: 1,
    expect: () => [
      isA<DiaryLoaded>().having((s) => s.isSaving, 'isSaving', true),
      isA<DiaryLoaded>().having((s) => s.entry?.updatedAt, 'updatedAt', fixedNow),
    ],
  );

  blocTest<DiaryCubit, DiaryState>(
    'saveReview with rating 0 leaves any existing rating untouched',
    setUp: () {
      when(() => repository.getEntry(1)).thenAnswer(
        (_) async => Ok(DiaryEntry(gameId: 1, status: PlayStatus.backlog, rating: 3, updatedAt: DateTime(2026, 1, 1))),
      );
      when(() => repository.saveEntry(any())).thenAnswer((_) async => const Ok(Unit.instance));
    },
    build: () => DiaryCubit(getDiaryEntry, saveDiaryEntry, 1, clock),
    act: (cubit) => cubit.saveReview(rating: 0, note: 'Just a note'),
    skip: 1,
    expect: () => [
      isA<DiaryLoaded>().having((s) => s.isSaving, 'isSaving', true),
      isA<DiaryLoaded>().having((s) => s.entry?.rating, 'rating', 3),
    ],
  );
}
