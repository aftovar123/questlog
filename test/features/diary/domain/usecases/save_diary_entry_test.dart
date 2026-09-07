import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';
import 'package:questlog/features/diary/domain/usecases/save_diary_entry.dart';

class _MockDiaryRepository extends Mock implements DiaryRepository {}

void main() {
  late _MockDiaryRepository repository;
  late SaveDiaryEntry useCase;

  setUp(() {
    repository = _MockDiaryRepository();
    useCase = SaveDiaryEntry(repository);
  });

  final entry = DiaryEntry(gameId: 7, status: PlayStatus.completed, rating: 5, updatedAt: DateTime(2026, 1, 1));

  test('saves the entry through the repository', () async {
    when(() => repository.saveEntry(entry)).thenAnswer((_) async => const Ok(Unit.instance));

    final result = await useCase(entry);

    expect(result, isA<Ok<Unit>>());
    verify(() => repository.saveEntry(entry)).called(1);
  });

  test('propagates a storage failure', () async {
    when(() => repository.saveEntry(entry)).thenAnswer((_) async => const Err(StorageFailure()));

    final result = await useCase(entry);

    expect(result, isA<Err<Unit>>());
  });
}
