import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';

class GetGames {
  const GetGames(this._repository);
  final GamesRepository _repository;

  Future<Result<List<Game>>> call({int page = 1, String? search}) {
    return _repository.getGames(page: page, search: search);
  }
}
