import 'package:questlog/features/games/domain/entities/game.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.rating,
    super.releaseDate,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Sin título',
      imageUrl: json['background_image'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      releaseDate: DateTime.tryParse(json['released'] as String? ?? ''),
    );
  }
}
