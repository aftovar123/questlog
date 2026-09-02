import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/entities/games_page.dart';
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
  const moreGames = [Game(id: 2, name: 'Celeste', imageUrl: null, rating: 4.6)];

  blocTest<GamesCubit, GamesState>(
    'emits [GamesLoading, GamesLoaded] when the repository returns games',
    setUp: () {
      when(
        () => repository.getGames(page: 1, search: null, genre: null),
      ).thenAnswer((_) async => const Ok(GamesPage(games: games, hasMore: false)));
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
      ).thenAnswer((_) async => const Ok(GamesPage(games: [], hasMore: false)));
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
      ).thenAnswer((_) async => const Ok(GamesPage(games: games, hasMore: false)));
    },
    build: () => GamesCubit(getGames),
    act: (cubit) => cubit.loadGames(genre: 'action'),
    expect: () => [const GamesLoading(), const GamesLoaded(games)],
  );

  blocTest<GamesCubit, GamesState>(
    'loadMore appends the next page and keeps hasMore in sync',
    setUp: () {
      when(
        () => repository.getGames(page: 2, search: null, genre: null),
      ).thenAnswer((_) async => const Ok(GamesPage(games: moreGames, hasMore: false)));
    },
    build: () => GamesCubit(getGames),
    seed: () => const GamesLoaded(games, hasMore: true),
    act: (cubit) => cubit.loadMore(),
    expect: () => [
      const GamesLoaded(games, hasMore: true, isLoadingMore: true),
      const GamesLoaded([...games, ...moreGames]),
    ],
  );

  blocTest<GamesCubit, GamesState>(
    'loadMore does nothing when there is no next page',
    build: () => GamesCubit(getGames),
    seed: () => const GamesLoaded(games),
    act: (cubit) => cubit.loadMore(),
    expect: () => <GamesState>[],
    verify: (_) {
      verifyNever(
        () => repository.getGames(
          page: any(named: 'page'),
          search: any(named: 'search'),
          genre: any(named: 'genre'),
        ),
      );
    },
  );

  test(
    'ignores a stale response from an earlier request that resolves later',
    () async {
      final firstRequest = Completer<Result<GamesPage>>();
      final secondRequest = Completer<Result<GamesPage>>();
      var callCount = 0;
      when(() => repository.getGames(page: 1, search: null, genre: null)).thenAnswer((_) {
        callCount++;
        return callCount == 1 ? firstRequest.future : secondRequest.future;
      });

      final cubit = GamesCubit(getGames);
      final firstCall = cubit.loadGames();
      final secondCall = cubit.loadGames(); // supersedes the first before it resolves

      // The newer request resolves first; the stale one resolves after.
      secondRequest.complete(const Ok(GamesPage(games: moreGames, hasMore: false)));
      await secondCall;
      firstRequest.complete(const Ok(GamesPage(games: games, hasMore: false)));
      await firstCall;

      expect(cubit.state, const GamesLoaded(moreGames));
      await cubit.close();
    },
  );
}
