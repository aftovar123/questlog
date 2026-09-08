import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';

class _MockDiaryRepository extends Mock implements DiaryRepository {}

void main() {
  late _MockDiaryRepository repository;
  late GetAllDiaryEntries useCase;

  setUp(() {
    repository = _MockDiaryRepository();
    useCase = GetAllDiaryEntries(repository);
  });

  test('returns every saved entry from the repository', () async {
    final entries = [
      DiaryEntry(gameId: 1, status: PlayStatus.playing, updatedAt: DateTime(2026, 1, 2)),
      DiaryEntry(gameId: 2, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 1)),
    ];
    when(() => repository.getAllEntries()).thenAnswer((_) async => Ok(entries));

    final result = await useCase();

    expect(result, isA<Ok<List<DiaryEntry>>>());
    expect((result as Ok<List<DiaryEntry>>).value, entries);
  });

  test('returns an empty list when nothing has been saved yet', () async {
    when(() => repository.getAllEntries()).thenAnswer((_) async => const Ok([]));

    final result = await useCase();

    expect((result as Ok<List<DiaryEntry>>).value, isEmpty);
  });

  test('propagates a storage failure', () async {
    when(() => repository.getAllEntries()).thenAnswer((_) async => const Err(StorageFailure()));

    final result = await useCase();

    expect(result, isA<Err<List<DiaryEntry>>>());
  });
}
