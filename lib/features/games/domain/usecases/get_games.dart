import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/games_page.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';

class GetGames {
  const GetGames(this._repository);
  final GamesRepository _repository;

  Future<Result<GamesPage>> call({int page = 1, String? search, String? genre}) {
    return _repository.getGames(page: page, search: search, genre: genre);
  }
}
