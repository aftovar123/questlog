import 'package:equatable/equatable.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';

sealed class DiaryState extends Equatable {
  const DiaryState();

  @override
  List<Object?> get props => [];
}

final class DiaryLoading extends DiaryState {
  const DiaryLoading();
}

/// `entry` is null when the player hasn't added this game to their diary
/// yet — the UI shows the picker with nothing selected, not an error.
final class DiaryLoaded extends DiaryState {
  const DiaryLoaded(this.entry, {this.isSaving = false, this.error});

  final DiaryEntry? entry;
  final bool isSaving;
  final String? error;

  @override
  List<Object?> get props => [entry, isSaving, error];
}
