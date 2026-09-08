import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/data/datasources/diary_local_data_source.dart';
import 'package:questlog/features/diary/data/models/diary_entry_model.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  const DiaryRepositoryImpl(this._localDataSource);
  final DiaryLocalDataSource _localDataSource;

  @override
  Future<Result<DiaryEntry?>> getEntry(int gameId) async {
    try {
      return Ok(_localDataSource.read(gameId));
    } catch (_) {
      return const Err(StorageFailure());
    }
  }

  @override
  Future<Result<List<DiaryEntry>>> getAllEntries() async {
    try {
      final entries = _localDataSource.readAll()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Ok(entries);
    } catch (_) {
      return const Err(StorageFailure());
    }
  }

  @override
  Future<Result<Unit>> saveEntry(DiaryEntry entry) async {
    try {
      await _localDataSource.write(DiaryEntryModel.fromEntity(entry));
      return const Ok(Unit.instance);
    } catch (_) {
      return const Err(StorageFailure());
    }
  }

  @override
  Future<Result<Unit>> deleteEntry(int gameId) async {
    try {
      await _localDataSource.delete(gameId);
      return const Ok(Unit.instance);
    } catch (_) {
      return const Err(StorageFailure());
    }
  }
}
