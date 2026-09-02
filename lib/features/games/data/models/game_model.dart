import 'package:questlog/features/games/domain/entities/game.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.rating,
    super.releaseDate,
    super.genres,
    super.platforms,
    super.description,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Sin título',
      imageUrl: json['background_image'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      releaseDate: DateTime.tryParse(json['released'] as String? ?? ''),
      genres: _namesFrom(json['genres']),
      platforms: _platformNamesFrom(json['platforms']),
      description: _cleanDescription(json['description_raw'] as String?),
    );
  }

  static List<String> _namesFrom(dynamic rawList) {
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((entry) => entry['name'] as String?)
        .whereType<String>()
        .toList();
  }

  static List<String> _platformNamesFrom(dynamic rawList) {
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(
          (entry) =>
              (entry['platform'] as Map<String, dynamic>?)?['name'] as String?,
        )
        .whereType<String>()
        .toList();
  }

  static String? _cleanDescription(String? raw) {
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
