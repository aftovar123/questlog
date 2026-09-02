import 'package:dio/dio.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/data/datasources/games_remote_data_source.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/entities/games_page.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';

class GamesRepositoryImpl implements GamesRepository {
  const GamesRepositoryImpl(this._remoteDataSource);
  final GamesRemoteDataSource _remoteDataSource;

  @override
  Future<Result<GamesPage>> getGames({
    int page = 1,
    String? search,
    String? genre,
  }) async {
    try {
      final games = await _remoteDataSource.fetchGames(
        page: page,
        search: search,
        genre: genre,
      );
      // RAWG doesn't hand us a cheap "is this the last page" flag here, so a
      // short page is the signal: if it came back full, there's probably more.
      final hasMore = games.length == GamesRemoteDataSource.pageSize;
      return Ok(GamesPage(games: games, hasMore: hasMore));
    } on DioException catch (error) {
      return Err(_mapError(error));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<Game>> getGameDetail(int id) async {
    try {
      final game = await _remoteDataSource.fetchGameDetail(id);
      return Ok(game);
    } on DioException catch (error) {
      return Err(_mapError(error));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  Failure _mapError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return ServerFailure(
          'El servidor respondió ${error.response?.statusCode}. Intenta más tarde.',
        );
      default:
        return const UnknownFailure();
    }
  }
}
