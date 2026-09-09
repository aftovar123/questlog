import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:questlog/core/network/rawg_dio_client.dart';
import 'package:questlog/core/network/session_expired_notifier.dart';
import 'package:questlog/features/diary/data/datasources/diary_local_data_source.dart';
import 'package:questlog/features/diary/data/repositories/diary_repository_impl.dart';
import 'package:questlog/features/diary/domain/repositories/diary_repository.dart';
import 'package:questlog/features/diary/domain/usecases/delete_diary_entry.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';
import 'package:questlog/features/diary/domain/usecases/get_diary_entry.dart';
import 'package:questlog/features/diary/domain/usecases/save_diary_entry.dart';
import 'package:questlog/features/games/data/datasources/games_remote_data_source.dart';
import 'package:questlog/features/games/data/repositories/games_repository_impl.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';
import 'package:questlog/features/games/domain/usecases/get_games.dart';

final getIt = GetIt.instance;

const diaryBoxName = 'diary';

Future<void> configureDependencies() async {
  getIt
    ..registerLazySingleton(() => SessionExpiredNotifier())
    ..registerLazySingleton<Dio>(() => buildRawgDioClient(getIt()))
    ..registerLazySingleton(() => GamesRemoteDataSource(getIt()))
    ..registerLazySingleton<GamesRepository>(() => GamesRepositoryImpl(getIt()))
    ..registerFactory(() => GetGames(getIt()))
    ..registerFactory(() => GetGameDetail(getIt()));

  await Hive.initFlutter();
  final diaryBox = await Hive.openBox<Map>(diaryBoxName);

  getIt
    ..registerLazySingleton(() => DiaryLocalDataSource(diaryBox))
    ..registerLazySingleton<DiaryRepository>(() => DiaryRepositoryImpl(getIt()))
    ..registerFactory(() => GetDiaryEntry(getIt()))
    ..registerFactory(() => GetAllDiaryEntries(getIt()))
    ..registerFactory(() => SaveDiaryEntry(getIt()))
    ..registerFactory(() => DeleteDiaryEntry(getIt()));
}
