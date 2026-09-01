import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:questlog/core/network/rawg_dio_client.dart';
import 'package:questlog/features/games/data/datasources/games_remote_data_source.dart';
import 'package:questlog/features/games/data/repositories/games_repository_impl.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';
import 'package:questlog/features/games/domain/usecases/get_games.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt
    ..registerLazySingleton<Dio>(buildRawgDioClient)
    ..registerLazySingleton(() => GamesRemoteDataSource(getIt()))
    ..registerLazySingleton<GamesRepository>(() => GamesRepositoryImpl(getIt()))
    ..registerFactory(() => GetGames(getIt()));
}
