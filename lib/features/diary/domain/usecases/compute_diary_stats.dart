import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/diary_stats.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

/// Pure function of already-loaded data (no repository, no async) so it's
/// directly testable with plain in-memory entries — the same shape as
/// `GamesRemoteDataSource.parseGamesResponse`. [gamesById] only needs to
/// contain entries for games whose enrichment succeeded; a missing id just
/// means that entry doesn't contribute genre data, same as it already
/// degrades gracefully in `DiaryListCubit`.
DiaryStats computeDiaryStats(List<DiaryEntry> entries, Map<int, Game> gamesById) {
  if (entries.isEmpty) {
    return const DiaryStats(
      totalTracked: 0,
      completedCount: 0,
      averageRating: null,
      topGenre: null,
      topGenreCount: 0,
    );
  }

  final completedCount = entries.where((entry) => entry.status == PlayStatus.completed).length;

  final ratings = entries.map((entry) => entry.rating).whereType<int>().toList();
  final averageRating = ratings.isEmpty ? null : ratings.reduce((a, b) => a + b) / ratings.length;

  final genreCounts = <String, int>{};
  for (final entry in entries) {
    final game = gamesById[entry.gameId];
    if (game == null) continue;
    for (final genre in game.genres) {
      genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
    }
  }

  String? topGenre;
  var topGenreCount = 0;
  for (final MapEntry(key: genre, value: count) in genreCounts.entries) {
    if (count > topGenreCount) {
      topGenre = genre;
      topGenreCount = count;
    }
  }

  return DiaryStats(
    totalTracked: entries.length,
    completedCount: completedCount,
    averageRating: averageRating,
    topGenre: topGenre,
    topGenreCount: topGenreCount,
  );
}
