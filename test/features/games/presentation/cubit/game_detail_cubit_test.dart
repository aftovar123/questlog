import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';
import 'package:questlog/features/games/presentation/cubit/game_detail_cubit.dart';
import 'package:questlog/features/games/presentation/cubit/game_detail_state.dart';

class _MockGamesRepository extends Mock implements GamesRepository {}

void main() {
  late _MockGamesRepository repository;
  late GetGameDetail getGameDetail;

  setUp(() {
    repository = _MockGamesRepository();
    getGameDetail = GetGameDetail(repository);
  });

  const initialGame = Game(id: 1, name: 'Hades', imageUrl: null, rating: 4.8);
  const enrichedGame = Game(
    id: 1,
    name: 'Hades',
    imageUrl: null,
    rating: 4.8,
    genres: ['Action', 'Indie'],
    description: 'A rogue-like dungeon crawler.',
  );

  test('starts in GameDetailLoading with the game passed via navigation', () {
    when(
      () => repository.getGameDetail(1),
    ).thenAnswer((_) async => const Ok(enrichedGame));

    final cubit = GameDetailCubit(getGameDetail, initialGame);

    expect(cubit.state, const GameDetailLoading(initialGame));
  });

  blocTest<GameDetailCubit, GameDetailState>(
    'emits GameDetailLoaded with the enriched game when the detail call succeeds',
    setUp: () {
      when(
        () => repository.getGameDetail(1),
      ).thenAnswer((_) async => const Ok(enrichedGame));
    },
    build: () => GameDetailCubit(getGameDetail, initialGame),
    expect: () => [const GameDetailLoaded(enrichedGame)],
  );

  blocTest<GameDetailCubit, GameDetailState>(
    'falls back to the initial game when the detail call fails',
    setUp: () {
      when(
        () => repository.getGameDetail(1),
      ).thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: () => GameDetailCubit(getGameDetail, initialGame),
    expect: () => [const GameDetailLoaded(initialGame)],
  );
}
