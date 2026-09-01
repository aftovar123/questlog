import 'package:equatable/equatable.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    this.releaseDate,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final double rating;
  final DateTime? releaseDate;

  @override
  List<Object?> get props => [id, name, imageUrl, rating, releaseDate];
}
