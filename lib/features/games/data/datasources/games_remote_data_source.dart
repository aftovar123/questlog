import 'package:dio/dio.dart';
import 'package:questlog/features/games/data/models/game_model.dart';

class GamesRemoteDataSource {
  const GamesRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<GameModel>> fetchGames({
    int page = 1,
    String? search,
    String? genre,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/games',
      queryParameters: {
        'page': page,
        'page_size': 20,
        if (search != null && search.isNotEmpty) 'search': search,
        if (genre != null && genre.isNotEmpty) 'genres': genre,
      },
    );

    final results = (response.data?['results'] as List<dynamic>?) ?? [];
    return results
        .map((json) => GameModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<GameModel> fetchGameDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/games/$id');
    return GameModel.fromJson(response.data ?? {});
  }
}
