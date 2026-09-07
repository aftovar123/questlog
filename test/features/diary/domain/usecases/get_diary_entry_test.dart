import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';
import 'package:questlog/features/diary/domain/usecases/get_diary_entry.dart';

class _MockDiaryRepository extends Mock implements DiaryRepository {}

void main() {
  late _MockDiaryRepository repository;
  late GetDiaryEntry useCase;

  setUp(() {
    repository = _MockDiaryRepository();
    useCase = GetDiaryEntry(repository);
  });

  final entry = DiaryEntry(gameId: 42, status: PlayStatus.playing, updatedAt: DateTime(2026, 1, 1));

  test('returns the saved entry for a game', () async {
    when(() => repository.getEntry(42)).thenAnswer((_) async => Ok(entry));

    final result = await useCase(42);

    expect(result, isA<Ok<DiaryEntry?>>());
    expect((result as Ok<DiaryEntry?>).value, entry);
  });

  test('returns null when the game has no diary entry yet', () async {
    when(() => repository.getEntry(99)).thenAnswer((_) async => const Ok(null));

    final result = await useCase(99);

    expect((result as Ok<DiaryEntry?>).value, isNull);
  });

  test('propagates a storage failure', () async {
    when(() => repository.getEntry(42)).thenAnswer((_) async => const Err(StorageFailure()));

    final result = await useCase(42);

    expect(result, isA<Err<DiaryEntry?>>());
  });
}
