// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Questlog';

  @override
  String get gamesListTitle => 'Games';

  @override
  String get searchHint => 'Search a game...';

  @override
  String get emptyGamesMessage => 'No games found.';

  @override
  String get loadingLabel => 'Loading games...';

  @override
  String get retryLabel => 'Retry';
}
