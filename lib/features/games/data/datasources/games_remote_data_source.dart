import 'package:dio/dio.dart';
import 'package:questlog/features/games/data/models/game_model.dart';
import 'package:questlog/features/games/data/models/genre_model.dart';

class GamesRemoteDataSource {
  const GamesRemoteDataSource(this._dio);
  final Dio _dio;

  /// How many results to ask RAWG for per page.
  static const pageSize = 20;

  Future<({List<GameModel> games, bool hasMore})> fetchGames({
    int page = 1,
    String? search,
    String? genre,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/games',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (genre != null && genre.isNotEmpty) 'genres': genre,
      },
    );

    return parseGamesResponse(response.data ?? {});
  }

  /// Pulled out as a pure function of a JSON map (no Dio needed) so it's
  /// directly testable — RAWG's response is standard DRF pagination: a
  /// `next` field that's a URL when another page exists, `null` on the
  /// last one. That's the real, free signal, instead of guessing from
  /// whether the page happened to come back full.
  static ({List<GameModel> games, bool hasMore}) parseGamesResponse(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>?) ?? [];
    final games = results
        .map((entry) => GameModel.fromJson(entry as Map<String, dynamic>))
        .toList();
    return (games: games, hasMore: json['next'] != null);
  }

  Future<GameModel> fetchGameDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/games/$id');
    return GameModel.fromJson(response.data ?? {});
  }

  Future<List<GenreModel>> fetchGenres() async {
    // RAWG's genre taxonomy is ~19 entries, well under one default page —
    // no pagination needed to get the full list in one call.
    final response = await _dio.get<Map<String, dynamic>>('/genres');
    final results = (response.data?['results'] as List<dynamic>?) ?? [];
    return results
        .map((json) => GenreModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
