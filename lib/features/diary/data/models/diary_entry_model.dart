import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';

class DiaryEntryModel extends DiaryEntry {
  const DiaryEntryModel({
    required super.gameId,
    required super.status,
    required super.updatedAt,
    super.rating,
    super.note,
  });

  factory DiaryEntryModel.fromEntity(DiaryEntry entry) {
    return DiaryEntryModel(
      gameId: entry.gameId,
      status: entry.status,
      updatedAt: entry.updatedAt,
      rating: entry.rating,
      note: entry.note,
    );
  }

  /// Hive stores `DateTime` and primitives natively — no JSON round-trip
  /// needed here, unlike the games feature parsing a real HTTP response.
  factory DiaryEntryModel.fromMap(int gameId, Map<dynamic, dynamic> map) {
    return DiaryEntryModel(
      gameId: gameId,
      status: PlayStatus.fromStorageValue(map['status'] as String? ?? ''),
      updatedAt: map['updatedAt'] as DateTime? ?? DateTime.now(),
      rating: map['rating'] as int?,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.toStorageValue(),
      'updatedAt': updatedAt,
      'rating': rating,
      'note': note,
    };
  }
}
