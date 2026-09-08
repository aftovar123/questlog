import 'package:equatable/equatable.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/games/domain/entities/game.dart';

/// A diary entry paired with the game it points to. [game] is null when the
/// enrichment call for that specific entry failed — the entry itself (status,
/// rating, note) still came from Hive and is shown with a generic fallback
/// instead of dropping the row entirely.
typedef DiaryListItem = ({DiaryEntry entry, Game? game});

sealed class DiaryListState extends Equatable {
  const DiaryListState();

  @override
  List<Object?> get props => [];
}

class DiaryListLoading extends DiaryListState {
  const DiaryListLoading();
}

class DiaryListEmpty extends DiaryListState {
  const DiaryListEmpty();
}

class DiaryListLoaded extends DiaryListState {
  const DiaryListLoaded(this.items);
  final List<DiaryListItem> items;

  @override
  List<Object?> get props => [items];
}

class DiaryListFailed extends DiaryListState {
  const DiaryListFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
