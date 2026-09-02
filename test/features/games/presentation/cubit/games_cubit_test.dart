import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';
import 'package:questlog/features/games/domain/usecases/get_games.dart';
import 'package:questlog/features/games/presentation/cubit/games_cubit.dart';
import 'package:questlog/features/games/presentation/cubit/games_state.dart';

class _MockGamesRepository extends Mock implements GamesRepository {}

void main() {
  late _MockGamesRepository repository;
  late GetGames getGames;

  setUp(() {
    repository = _MockGamesRepository();
    getGames = GetGames(repository);
  });

  const games = [Game(id: 1, name: 'Hades', imageUrl: null, rating: 4.8)];

  blocTest<GamesCubit, GamesState>(
    'emits [GamesLoading, GamesLoaded] when the repository returns games',
    setUp: () {
      when(
        () => repository.getGames(page: 1, search: null, genre: null),
      ).thenAnswer((_) async => const Ok(games));
    },
    build: () => GamesCubit(getGames),
    act: (cubit) => cubit.loadGames(),
    expect: () => [const GamesLoading(), const GamesLoaded(games)],
  );

  blocTest<GamesCubit, GamesState>(
    'emits [GamesLoading, GamesEmpty] when the repository returns no games',
    setUp: () {
      when(
        () => repository.getGames(page: 1, search: null, genre: null),
      ).thenAnswer((_) async => const Ok([]));
    },
    build: () => GamesCubit(getGames),
    act: (cubit) => cubit.loadGames(),
    expect: () => [const GamesLoading(), const GamesEmpty()],
  );

  blocTest<GamesCubit, GamesState>(
    'emits [GamesLoading, GamesFailed] when the repository fails',
    setUp: () {
      when(
        () => repository.getGames(page: 1, search: null, genre: null),
      ).thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: () => GamesCubit(getGames),
    act: (cubit) => cubit.loadGames(),
    expect: () => [const GamesLoading(), isA<GamesFailed>()],
  );

  blocTest<GamesCubit, GamesState>(
    'forwards the genre filter to the use case',
    setUp: () {
      when(
        () => repository.getGames(page: 1, search: null, genre: 'action'),
      ).thenAnswer((_) async => const Ok(games));
    },
    build: () => GamesCubit(getGames),
    act: (cubit) => cubit.loadGames(genre: 'action'),
    expect: () => [const GamesLoading(), const GamesLoaded(games)],
  );
}
