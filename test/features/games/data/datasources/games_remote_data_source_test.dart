import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/features/games/data/datasources/games_remote_data_source.dart';

void main() {
  group('GamesRemoteDataSource.parseGamesResponse', () {
    test('hasMore is true when RAWG provides a next-page URL', () {
      final result = GamesRemoteDataSource.parseGamesResponse({
        'count': 900860,
        'next': 'https://api.rawg.io/api/games?page=2',
        'previous': null,
        'results': [
          {'id': 3498, 'name': 'Grand Theft Auto V'},
        ],
      });

      expect(result.games, hasLength(1));
      expect(result.games.first.id, 3498);
      expect(result.hasMore, isTrue);
    });

    test('hasMore is false on the last page, where next is null', () {
      final result = GamesRemoteDataSource.parseGamesResponse({
        'count': 900860,
        'next': null,
        'previous': 'https://api.rawg.io/api/games?page=45042',
        'results': [
          {'id': 2015, 'name': 'Catan HD'},
        ],
      });

      expect(result.hasMore, isFalse);
    });

    test('a full page that is still the last one correctly reports hasMore: false', () {
      // The exact case the old page-size heuristic got wrong: a page that
      // comes back full isn't necessarily followed by another one.
      final fullButLastPage = {
        'next': null,
        'results': List.generate(20, (i) => {'id': i, 'name': 'Game $i'}),
      };

      final result = GamesRemoteDataSource.parseGamesResponse(fullButLastPage);

      expect(result.games, hasLength(20));
      expect(result.hasMore, isFalse);
    });

    test('falls back to an empty list when results is missing', () {
      final result = GamesRemoteDataSource.parseGamesResponse(const {'next': null});

      expect(result.games, isEmpty);
      expect(result.hasMore, isFalse);
    });
  });
}
