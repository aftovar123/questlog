import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/genre.dart';
import 'package:questlog/features/games/domain/repositories/games_repository.dart';

class GetGenres {
  const GetGenres(this._repository);
  final GamesRepository _repository;

  Future<Result<List<Genre>>> call() => _repository.getGenres();
}
