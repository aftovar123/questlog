import 'package:dio/dio.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/data/datasources/games_remote_data_source.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';

class GamesRepositoryImpl implements GamesRepository {
  const GamesRepositoryImpl(this._remoteDataSource);
  final GamesRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Game>>> getGames({int page = 1, String? search}) async {
    try {
      final games = await _remoteDataSource.fetchGames(page: page, search: search);
      return Ok(games);
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
