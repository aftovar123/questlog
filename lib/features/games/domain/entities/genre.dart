import 'package:equatable/equatable.dart';

/// A RAWG genre — `slug` is what the API's `/games?genres=` filter expects,
/// `name` is what a human reads on the chip.
class Genre extends Equatable {
  const Genre({required this.id, required this.name, required this.slug});

  final int id;
  final String name;
  final String slug;

  @override
  List<Object?> get props => [id, name, slug];
}
