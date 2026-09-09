import 'package:equatable/equatable.dart';
import 'package:questlog/features/games/domain/entities/genre.dart';

sealed class GenresState extends Equatable {
  const GenresState();

  @override
  List<Object?> get props => [];
}

class GenresLoading extends GenresState {
  const GenresLoading();
}

class GenresLoaded extends GenresState {
  const GenresLoaded(this.genres);
  final List<Genre> genres;

  @override
  List<Object?> get props => [genres];
}
