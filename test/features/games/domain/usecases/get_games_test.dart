import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/entities/games_page.dart';
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
  const page = GamesPage(games: games, hasMore: false);

  test('returns the page of games when the repository succeeds', () async {
    when(
      () => repository.getGames(page: 1, search: null, genre: null),
    ).thenAnswer((_) async => const Ok(page));

    final result = await useCase();

    expect(result, isA<Ok<GamesPage>>());
    expect((result as Ok<GamesPage>).value, page);
  });

  test('propagates the failure when the repository fails', () async {
    when(
      () => repository.getGames(page: 1, search: null, genre: null),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    final result = await useCase();

    expect(result, isA<Err<GamesPage>>());
  });

  test('forwards the genre filter to the repository', () async {
    when(
      () => repository.getGames(page: 1, search: null, genre: 'action'),
    ).thenAnswer((_) async => const Ok(page));

    final result = await useCase(genre: 'action');

    expect(result, isA<Ok<GamesPage>>());
  });

  test('forwards the requested page to the repository', () async {
    when(
      () => repository.getGames(page: 2, search: null, genre: null),
    ).thenAnswer((_) async => const Ok(page));

    final result = await useCase(page: 2);

    expect(result, isA<Ok<GamesPage>>());
    verify(() => repository.getGames(page: 2, search: null, genre: null)).called(1);
  });
}
