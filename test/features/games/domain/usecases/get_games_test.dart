import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';
import 'package:questlog/features/games/domain/usecases/get_games.dart';

class _MockGamesRepository extends Mock implements GamesRepository {}

void main() {
  late _MockGamesRepository repository;
  late GetGames useCase;

  setUp(() {
    repository = _MockGamesRepository();
    useCase = GetGames(repository);
  });

  const games = [
    Game(id: 1, name: 'Hollow Knight', imageUrl: null, rating: 4.5),
  ];

  test('returns the list of games when the repository succeeds', () async {
    when(
      () => repository.getGames(page: 1, search: null, genre: null),
    ).thenAnswer((_) async => const Ok(games));

    final result = await useCase();

    expect(result, isA<Ok<List<Game>>>());
    expect((result as Ok<List<Game>>).value, games);
  });

  test('propagates the failure when the repository fails', () async {
    when(
      () => repository.getGames(page: 1, search: null, genre: null),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    final result = await useCase();

    expect(result, isA<Err<List<Game>>>());
  });

  test('forwards the genre filter to the repository', () async {
    when(
      () => repository.getGames(page: 1, search: null, genre: 'action'),
    ).thenAnswer((_) async => const Ok(games));

    final result = await useCase(genre: 'action');

    expect(result, isA<Ok<List<Game>>>());
  });
}
