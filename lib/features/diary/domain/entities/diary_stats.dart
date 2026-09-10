import 'package:equatable/equatable.dart';

/// A snapshot of the player's own diary, computed fresh from whatever is
/// currently persisted — never hardcoded or illustrative. If the diary is
/// empty every field here is empty/null/zero.
class DiaryStats extends Equatable {
  const DiaryStats({
    required this.totalTracked,
    required this.completedCount,
    required this.averageRating,
    required this.topGenre,
    required this.topGenreCount,
  });

  /// Every game marked in the diary, regardless of status.
  final int totalTracked;

  /// How many of those are marked Completed.
  final int completedCount;

  /// Mean of the entries that actually carry a 1-5 rating; null if none do
  /// (unrated entries don't count as zeros, they're just excluded).
  final double? averageRating;

  /// The genre appearing most often across the tracked games' own genre
  /// lists, or null if no tracked game has genre data at all.
  final String? topGenre;
  final int topGenreCount;

  @override
  List<Object?> get props => [totalTracked, completedCount, averageRating, topGenre, topGenreCount];
}
