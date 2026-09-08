import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

/// Shared between [DiarySection] and the "Mi diario" list so both show the
/// exact same label for a given status.
String diaryStatusLabel(AppLocalizations l10n, PlayStatus status) {
  return switch (status) {
    PlayStatus.backlog => l10n.diaryStatusBacklog,
    PlayStatus.playing => l10n.diaryStatusPlaying,
    PlayStatus.completed => l10n.diaryStatusCompleted,
  };
}
