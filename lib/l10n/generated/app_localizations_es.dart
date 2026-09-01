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
}
