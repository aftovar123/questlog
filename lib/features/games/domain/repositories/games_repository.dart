import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

/// Defined on the domain side and implemented by the data layer — the
/// use case that depends on this never knows Dio or RAWG exist.
abstract interface class GamesRepository {
  Future<Result<List<Game>>> getGames({int page = 1, String? search});
}
