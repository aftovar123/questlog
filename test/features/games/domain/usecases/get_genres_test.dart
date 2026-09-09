import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/genre.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';
import 'package:questlog/features/games/domain/usecases/get_genres.dart';

class _MockGamesRepository extends Mock implements GamesRepository {}

void main() {
  late _MockGamesRepository repository;
  late GetGenres useCase;

  setUp(() {
    repository = _MockGamesRepository();
    useCase = GetGenres(repository);
  });

  const genres = [
    Genre(id: 4, name: 'Action', slug: 'action'),
    Genre(id: 5, name: 'RPG', slug: 'role-playing-games-rpg'),
  ];

  test('returns the genre list when the repository succeeds', () async {
    when(() => repository.getGenres()).thenAnswer((_) async => const Ok(genres));

    final result = await useCase();

    expect(result, isA<Ok<List<Genre>>>());
    expect((result as Ok<List<Genre>>).value, genres);
  });

  test('propagates the failure when the repository fails', () async {
    when(() => repository.getGenres()).thenAnswer((_) async => const Err(NetworkFailure()));

    final result = await useCase();

    expect(result, isA<Err<List<Genre>>>());
  });
}
