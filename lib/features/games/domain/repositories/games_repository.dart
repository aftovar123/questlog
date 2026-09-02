import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/domain/entities/games_page.dart';

/// Defined on the domain side and implemented by the data layer — the
/// use case that depends on this never knows Dio or RAWG exist.
abstract interface class GamesRepository {
  Future<Result<GamesPage>> getGames({int page = 1, String? search, String? genre});

  Future<Result<Game>> getGameDetail(int id);
}
