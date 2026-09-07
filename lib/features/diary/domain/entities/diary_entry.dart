import 'package:equatable/equatable.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';

/// A player's personal record for one game — the "Letterboxd" part of
/// Questlog. Lives entirely on-device; RAWG has no idea this exists.
class DiaryEntry extends Equatable {
  const DiaryEntry({
    required this.gameId,
    required this.status,
    required this.updatedAt,
    this.rating,
    this.note,
  });

  final int gameId;
  final PlayStatus status;
  final DateTime updatedAt;

  /// 1 to 5, or null if the player hasn't rated it yet.
  final int? rating;
  final String? note;

  DiaryEntry copyWith({
    PlayStatus? status,
    DateTime? updatedAt,
    int? rating,
    String? note,
    bool clearNote = false,
  }) {
    return DiaryEntry(
      gameId: gameId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  @override
  List<Object?> get props => [gameId, status, updatedAt, rating, note];
}
