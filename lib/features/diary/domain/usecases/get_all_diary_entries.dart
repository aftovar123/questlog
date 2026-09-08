import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';

class GetAllDiaryEntries {
  const GetAllDiaryEntries(this._repository);
  final DiaryRepository _repository;

  Future<Result<List<DiaryEntry>>> call() => _repository.getAllEntries();
}
