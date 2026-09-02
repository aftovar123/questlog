import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';

class _MockGamesRepository extends Mock implements GamesRepository {}

void main() {
  late _MockGamesRepository repository;
  late GetGameDetail useCase;

  setUp(() {
    repository = _MockGamesRepository();
    useCase = GetGameDetail(repository);
  });

  const game = Game(
    id: 3498,
    name: 'Grand Theft Auto V',
    imageUrl: null,
    rating: 4.47,
    genres: ['Action', 'Adventure'],
    description: 'An open-world action-adventure game.',
  );

  test('returns the enriched game when the repository succeeds', () async {
    when(
      () => repository.getGameDetail(3498),
    ).thenAnswer((_) async => const Ok(game));

    final result = await useCase(3498);

    expect(result, isA<Ok<Game>>());
    expect((result as Ok<Game>).value, game);
  });

  test('propagates the failure when the repository fails', () async {
    when(
      () => repository.getGameDetail(3498),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    final result = await useCase(3498);

    expect(result, isA<Err<Game>>());
  });
}
