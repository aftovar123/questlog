import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/games/domain/entities/genre.dart';
import 'package:questlog/features/games/domain/usecases/get_genres.dart';
import 'package:questlog/features/games/presentation/cubit/genres_cubit.dart';
import 'package:questlog/features/games/presentation/cubit/genres_state.dart';

class _MockGetGenres extends Mock implements GetGenres {}

void main() {
  late _MockGetGenres getGenres;

  setUp(() {
    getGenres = _MockGetGenres();
  });

  const genres = [Genre(id: 4, name: 'Action', slug: 'action')];

  blocTest<GenresCubit, GenresState>(
    'emits GenresLoaded with the real list when the repository succeeds',
    setUp: () {
      when(() => getGenres()).thenAnswer((_) async => const Ok(genres));
    },
    build: () => GenresCubit(getGenres),
    expect: () => [const GenresLoaded(genres)],
  );

  blocTest<GenresCubit, GenresState>(
    'degrades to an empty list instead of an error state when the repository fails',
    setUp: () {
      when(() => getGenres()).thenAnswer((_) async => const Err(NetworkFailure()));
    },
    build: () => GenresCubit(getGenres),
    expect: () => [const GenresLoaded([])],
  );
}
