import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/features/games/data/models/game_model.dart';

void main() {
  test('GameModel.fromJson parses a RAWG game payload', () {
    final json = {
      'id': 3498,
      'name': 'Grand Theft Auto V',
      'background_image': 'https://example.com/gtav.jpg',
      'rating': 4.47,
      'released': '2013-09-17',
      'genres': [
        {'id': 4, 'name': 'Action'},
        {'id': 3, 'name': 'Adventure'},
      ],
      'platforms': [
        {'platform': {'id': 4, 'name': 'PC'}},
        {'platform': {'id': 187, 'name': 'PlayStation 5'}},
      ],
      'description_raw': 'An open-world action-adventure game.',
    };

    final game = GameModel.fromJson(json);

    expect(game.id, 3498);
    expect(game.name, 'Grand Theft Auto V');
    expect(game.imageUrl, 'https://example.com/gtav.jpg');
    expect(game.rating, 4.47);
    expect(game.releaseDate, DateTime.parse('2013-09-17'));
    expect(game.genres, ['Action', 'Adventure']);
    expect(game.platforms, ['PC', 'PlayStation 5']);
    expect(game.description, 'An open-world action-adventure game.');
  });

  test('GameModel.fromJson falls back gracefully on missing fields', () {
    final game = GameModel.fromJson(const {'id': 1});

    expect(game.name, 'Sin título');
    expect(game.imageUrl, isNull);
    expect(game.rating, 0);
    expect(game.releaseDate, isNull);
    expect(game.genres, isEmpty);
    expect(game.platforms, isEmpty);
    expect(game.description, isNull);
  });

  test('GameModel.fromJson treats a blank description_raw as absent', () {
    final game = GameModel.fromJson(const {'id': 1, 'description_raw': '   '});

    expect(game.description, isNull);
  });
}
