import 'package:questlog/features/games/domain/entities/genre.dart';

class GenreModel extends Genre {
  const GenreModel({required super.id, required super.name, required super.slug});

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}
