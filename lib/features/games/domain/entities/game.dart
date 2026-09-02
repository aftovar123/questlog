import 'package:equatable/equatable.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    this.releaseDate,
    this.genres = const [],
    this.platforms = const [],
    this.description,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final double rating;
  final DateTime? releaseDate;
  final List<String> genres;
  final List<String> platforms;
  final String? description;

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    rating,
    releaseDate,
    genres,
    platforms,
    description,
  ];
}
