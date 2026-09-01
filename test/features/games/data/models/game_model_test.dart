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
    };

    final game = GameModel.fromJson(json);

    expect(game.id, 3498);
    expect(game.name, 'Grand Theft Auto V');
    expect(game.imageUrl, 'https://example.com/gtav.jpg');
    expect(game.rating, 4.47);
    expect(game.releaseDate, DateTime.parse('2013-09-17'));
  });

  test('GameModel.fromJson falls back gracefully on missing fields', () {
    final game = GameModel.fromJson(const {'id': 1});

    expect(game.name, 'Sin título');
    expect(game.imageUrl, isNull);
    expect(game.rating, 0);
    expect(game.releaseDate, isNull);
  });
}
