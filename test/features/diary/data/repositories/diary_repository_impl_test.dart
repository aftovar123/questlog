import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/data/datasources/diary_local_data_source.dart';
import 'package:questlog/features/diary/data/repositories/diary_repository_impl.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';

// Unlike the games feature (mocked repository/data source), this test uses a
// real Hive instance backed by a temp directory — it's the persistence
// itself under test here, so a mock would just prove the mock works.
void main() {
  late Box<Map> box;
  late DiaryRepositoryImpl repository;

  setUp(() async {
    await setUpTestHive();
    box = await Hive.openBox<Map>('diary_test');
    repository = DiaryRepositoryImpl(DiaryLocalDataSource(box));
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('returns null when the game has no saved entry', () async {
    final result = await repository.getEntry(1);

    expect(result, isA<Ok<DiaryEntry?>>());
    expect((result as Ok<DiaryEntry?>).value, isNull);
  });

  test('round-trips a saved entry exactly', () async {
    final entry = DiaryEntry(
      gameId: 1,
      status: PlayStatus.playing,
      rating: 4,
      note: 'Great combat, slow start.',
      updatedAt: DateTime(2026, 9, 1, 10, 30),
    );

    await repository.saveEntry(entry);
    final result = await repository.getEntry(1);
    final loaded = (result as Ok<DiaryEntry?>).value;

    // DiaryLocalDataSource hands back a DiaryEntryModel — Equatable treats
    // that as a different runtimeType than a plain DiaryEntry even with
    // identical fields, so compare fields (same convention as GameModel).
    expect(loaded?.gameId, entry.gameId);
    expect(loaded?.status, entry.status);
    expect(loaded?.rating, entry.rating);
    expect(loaded?.note, entry.note);
    expect(loaded?.updatedAt, entry.updatedAt);
  });

  test('overwrites the previous entry for the same game', () async {
    final first = DiaryEntry(gameId: 1, status: PlayStatus.backlog, updatedAt: DateTime(2026, 1, 1));
    final second = DiaryEntry(gameId: 1, status: PlayStatus.completed, rating: 5, updatedAt: DateTime(2026, 2, 1));

    await repository.saveEntry(first);
    await repository.saveEntry(second);
    final result = await repository.getEntry(1);
    final loaded = (result as Ok<DiaryEntry?>).value;

    expect(loaded?.status, PlayStatus.completed);
    expect(loaded?.rating, 5);
  });

  test('deleteEntry removes the saved entry', () async {
    final entry = DiaryEntry(gameId: 2, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 1));
    await repository.saveEntry(entry);

    await repository.deleteEntry(2);
    final result = await repository.getEntry(2);

    expect((result as Ok<DiaryEntry?>).value, isNull);
  });

  test('getAllEntries returns an empty list when nothing is saved', () async {
    final result = await repository.getAllEntries();

    expect((result as Ok<List<DiaryEntry>>).value, isEmpty);
  });

  test('getAllEntries returns every saved entry, most recently updated first', () async {
    final older = DiaryEntry(gameId: 1, status: PlayStatus.backlog, updatedAt: DateTime(2026, 1, 1));
    final newer = DiaryEntry(gameId: 2, status: PlayStatus.playing, updatedAt: DateTime(2026, 3, 1));

    await repository.saveEntry(older);
    await repository.saveEntry(newer);
    final result = await repository.getAllEntries();
    final loaded = (result as Ok<List<DiaryEntry>>).value;

    expect(loaded.map((e) => e.gameId), [2, 1]);
  });

  test('entries for different games do not collide', () async {
    final entryA = DiaryEntry(gameId: 1, status: PlayStatus.playing, updatedAt: DateTime(2026, 1, 1));
    final entryB = DiaryEntry(gameId: 2, status: PlayStatus.backlog, updatedAt: DateTime(2026, 1, 1));

    await repository.saveEntry(entryA);
    await repository.saveEntry(entryB);

    final loadedA = (await repository.getEntry(1) as Ok<DiaryEntry?>).value;
    final loadedB = (await repository.getEntry(2) as Ok<DiaryEntry?>).value;

    expect(loadedA?.status, PlayStatus.playing);
    expect(loadedB?.status, PlayStatus.backlog);
  });
}
