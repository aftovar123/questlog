import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';

abstract interface class DiaryRepository {
  Future<Result<DiaryEntry?>> getEntry(int gameId);
  Future<Result<Unit>> saveEntry(DiaryEntry entry);
  Future<Result<Unit>> deleteEntry(int gameId);
}
