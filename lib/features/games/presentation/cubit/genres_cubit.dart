import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/usecases/get_genres.dart';
import 'package:questlog/features/games/presentation/cubit/genres_state.dart';

/// Genre chips are a filter, not core content — if RAWG's genre list fails
/// to load, the graceful degrade is just "Todos" alone, not an error screen
/// blocking the whole games list underneath it.
class GenresCubit extends Cubit<GenresState> {
  GenresCubit(this._getGenres) : super(const GenresLoading()) {
    _load();
  }

  final GetGenres _getGenres;

  Future<void> _load() async {
    final result = await _getGenres();
    switch (result) {
      case Ok(:final value):
        emit(GenresLoaded(value));
      case Err():
        emit(const GenresLoaded([]));
    }
  }
}
