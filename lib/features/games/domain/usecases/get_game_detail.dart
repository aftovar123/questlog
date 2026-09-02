import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';

class GetGameDetail {
  const GetGameDetail(this._repository);
  final GamesRepository _repository;

  Future<Result<Game>> call(int id) => _repository.getGameDetail(id);
}
