import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/domain/usecases/compute_diary_stats.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

void main() {
  group('computeDiaryStats', () {
    test('every field is empty/zero/null when there are no entries', () {
      final stats = computeDiaryStats(const [], const {});

      expect(stats.totalTracked, 0);
      expect(stats.completedCount, 0);
      expect(stats.averageRating, isNull);
      expect(stats.topGenre, isNull);
      expect(stats.topGenreCount, 0);
    });

    test('counts total tracked and completed regardless of rating or genre data', () {
      final entries = [
        DiaryEntry(gameId: 1, status: PlayStatus.backlog, updatedAt: DateTime(2026, 1, 1)),
        DiaryEntry(gameId: 2, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 2)),
        DiaryEntry(gameId: 3, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 3)),
      ];

      final stats = computeDiaryStats(entries, const {});

      expect(stats.totalTracked, 3);
      expect(stats.completedCount, 2);
    });

    test('averages only the entries that carry a rating, unrated ones do not count as zero', () {
      final entries = [
        DiaryEntry(gameId: 1, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 1), rating: 5),
        DiaryEntry(gameId: 2, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 2), rating: 3),
        DiaryEntry(gameId: 3, status: PlayStatus.backlog, updatedAt: DateTime(2026, 1, 3)),
      ];

      final stats = computeDiaryStats(entries, const {});

      expect(stats.averageRating, 4.0);
    });

    test('averageRating is null when no entry has been rated yet', () {
      final entries = [
        DiaryEntry(gameId: 1, status: PlayStatus.backlog, updatedAt: DateTime(2026, 1, 1)),
      ];

      final stats = computeDiaryStats(entries, const {});

      expect(stats.averageRating, isNull);
    });

    test('topGenre is the genre appearing most across tracked games, with its count', () {
      final entries = [
        DiaryEntry(gameId: 1, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 1)),
        DiaryEntry(gameId: 2, status: PlayStatus.playing, updatedAt: DateTime(2026, 1, 2)),
        DiaryEntry(gameId: 3, status: PlayStatus.backlog, updatedAt: DateTime(2026, 1, 3)),
      ];
      final gamesById = {
        1: const Game(id: 1, name: 'A', imageUrl: null, rating: 4, genres: ['RPG', 'Action']),
        2: const Game(id: 2, name: 'B', imageUrl: null, rating: 4, genres: ['RPG']),
        3: const Game(id: 3, name: 'C', imageUrl: null, rating: 4, genres: ['Puzzle']),
      };

      final stats = computeDiaryStats(entries, gamesById);

      expect(stats.topGenre, 'RPG');
      expect(stats.topGenreCount, 2);
    });

    test('topGenre is null when no tracked game has genre data', () {
      final entries = [
        DiaryEntry(gameId: 1, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 1)),
      ];
      final gamesById = {1: const Game(id: 1, name: 'A', imageUrl: null, rating: 4)};

      final stats = computeDiaryStats(entries, gamesById);

      expect(stats.topGenre, isNull);
      expect(stats.topGenreCount, 0);
    });

    test('an entry whose game enrichment failed (missing from gamesById) is skipped for genre, not crashed on', () {
      final entries = [
        DiaryEntry(gameId: 1, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 1)),
        DiaryEntry(gameId: 2, status: PlayStatus.completed, updatedAt: DateTime(2026, 1, 2)),
      ];
      final gamesById = {2: const Game(id: 2, name: 'B', imageUrl: null, rating: 4, genres: ['Action'])};

      final stats = computeDiaryStats(entries, gamesById);

      expect(stats.totalTracked, 2);
      expect(stats.topGenre, 'Action');
      expect(stats.topGenreCount, 1);
    });
  });
}
