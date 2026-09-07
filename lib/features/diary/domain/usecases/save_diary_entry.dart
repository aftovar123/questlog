import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';

class SaveDiaryEntry {
  const SaveDiaryEntry(this._repository);
  final DiaryRepository _repository;

  Future<Result<Unit>> call(DiaryEntry entry) => _repository.saveEntry(entry);
}
