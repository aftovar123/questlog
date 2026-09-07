import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';

class GetDiaryEntry {
  const GetDiaryEntry(this._repository);
  final DiaryRepository _repository;

  Future<Result<DiaryEntry?>> call(int gameId) => _repository.getEntry(gameId);
}
