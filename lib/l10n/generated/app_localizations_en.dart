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

  @override
  String get allGenresLabel => 'All';

  @override
  String get genresLabel => 'Genres';

  @override
  String get platformsLabel => 'Platforms';

  @override
  String get aboutLabel => 'About';

  @override
  String get readMoreLabel => 'Read more';

  @override
  String get readLessLabel => 'Read less';

  @override
  String get diaryTitle => 'My diary';

  @override
  String get diaryStatusBacklog => 'Backlog';

  @override
  String get diaryStatusPlaying => 'Playing';

  @override
  String get diaryStatusCompleted => 'Completed';

  @override
  String get diaryRatingLabel => 'Rating';

  @override
  String get diaryNoteHint => 'Write a review or personal note...';

  @override
  String get diarySaveReviewLabel => 'Save review';

  @override
  String get diaryEditReviewLabel => 'Edit';

  @override
  String get diarySavedLabel => 'Saved';

  @override
  String get diaryErrorLabel => 'Couldn\'t save. Try again.';

  @override
  String get myDiaryEmptyMessage =>
      'You haven\'t added any games to your diary yet.';

  @override
  String get diaryUpdatedLabel => 'Updated';
}
