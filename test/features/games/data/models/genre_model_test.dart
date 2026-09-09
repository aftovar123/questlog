import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/features/games/data/models/genre_model.dart';

void main() {
  test('GenreModel.fromJson parses a RAWG genre payload', () {
    final genre = GenreModel.fromJson(const {'id': 4, 'name': 'Action', 'slug': 'action'});

    expect(genre.id, 4);
    expect(genre.name, 'Action');
    expect(genre.slug, 'action');
  });

  test('GenreModel.fromJson falls back gracefully on missing fields', () {
    final genre = GenreModel.fromJson(const {'id': 4});

    expect(genre.name, '');
    expect(genre.slug, '');
  });
}
