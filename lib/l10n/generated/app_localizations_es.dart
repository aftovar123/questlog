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
}
