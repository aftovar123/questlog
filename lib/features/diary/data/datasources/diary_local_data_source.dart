import 'package:hive/hive.dart';
import 'package:questlog/features/diary/data/models/diary_entry_model.dart';

class DiaryLocalDataSource {
  const DiaryLocalDataSource(this._box);

  final Box<Map> _box;

  DiaryEntryModel? read(int gameId) {
    final map = _box.get(gameId.toString());
    if (map == null) return null;
    return DiaryEntryModel.fromMap(gameId, map);
  }

  List<DiaryEntryModel> readAll() {
    return [
      for (final key in _box.keys)
        DiaryEntryModel.fromMap(int.parse(key as String), _box.get(key)!),
    ];
  }

  Future<void> write(DiaryEntryModel entry) {
    return _box.put(entry.gameId.toString(), entry.toMap());
  }

  Future<void> delete(int gameId) => _box.delete(gameId.toString());
}
