import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';

class DeleteDiaryEntry {
  const DeleteDiaryEntry(this._repository);
  final DiaryRepository _repository;

  Future<Result<Unit>> call(int gameId) => _repository.deleteEntry(gameId);
}
