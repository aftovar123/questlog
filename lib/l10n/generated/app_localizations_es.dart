// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Questlog';

  @override
  String get gamesListTitle => 'Juegos';

  @override
  String get searchHint => 'Buscar un juego...';

  @override
  String get emptyGamesMessage => 'No se encontraron juegos.';

  @override
  String get loadingLabel => 'Cargando juegos...';

  @override
  String get retryLabel => 'Reintentar';

  @override
  String get allGenresLabel => 'Todos';

  @override
  String get genresLabel => 'Géneros';

  @override
  String get platformsLabel => 'Plataformas';

  @override
  String get aboutLabel => 'Acerca de';

  @override
  String get readMoreLabel => 'Leer más';

  @override
  String get readLessLabel => 'Leer menos';

  @override
  String get diaryTitle => 'Mi diario';

  @override
  String get diaryStatusBacklog => 'Backlog';

  @override
  String get diaryStatusPlaying => 'Jugando';

  @override
  String get diaryStatusCompleted => 'Completado';

  @override
  String get diaryRatingLabel => 'Calificación';

  @override
  String get diaryNoteHint => 'Escribe una reseña o nota personal...';

  @override
  String get diarySaveReviewLabel => 'Guardar reseña';

  @override
  String get diaryEditReviewLabel => 'Editar';

  @override
  String get diarySavedLabel => 'Guardado';

  @override
  String get diaryErrorLabel => 'No se pudo guardar. Intenta de nuevo.';

  @override
  String get myDiaryEmptyMessage =>
      'Todavía no has agregado juegos a tu diario.';

  @override
  String get diaryUpdatedLabel => 'Actualizado';
}
