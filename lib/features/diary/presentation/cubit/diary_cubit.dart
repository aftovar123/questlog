import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/core/result.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/domain/usecases/get_diary_entry.dart';
import 'package:questlog/features/diary/domain/usecases/save_diary_entry.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_state.dart';

class DiaryCubit extends Cubit<DiaryState> {
  DiaryCubit(this._getDiaryEntry, this._saveDiaryEntry, this._gameId)
    : super(const DiaryLoading()) {
    _ready = _load();
  }

  final GetDiaryEntry _getDiaryEntry;
  final SaveDiaryEntry _saveDiaryEntry;
  final int _gameId;

  // Guards against a real race: if a status/rating/note update comes in
  // before the initial read finishes, awaiting this first makes sure it's
  // applied on top of the loaded entry instead of silently no-op'ing.
  late final Future<void> _ready;

  Future<void> _load() async {
    final result = await _getDiaryEntry(_gameId);
    switch (result) {
      case Ok(:final value):
        emit(DiaryLoaded(value));
      case Err():
        // A local read failing shouldn't block the whole page — just start
        // from an empty diary entry instead of showing an error state.
        emit(const DiaryLoaded(null));
    }
  }

  Future<void> updateStatus(PlayStatus status) {
    return _updateAndSave((current) => current.copyWith(status: status));
  }

  /// Rating and note are saved together, in one call, so tapping through a
  /// few stars while deciding on a score doesn't fire a save (and a "Saved"
  /// confirmation) per tap — only the explicit "Save review" action does.
  Future<void> saveReview({required int rating, required String note}) {
    final trimmed = note.trim();
    return _updateAndSave((current) {
      final withNote = current.copyWith(note: trimmed, clearNote: trimmed.isEmpty);
      return rating > 0 ? withNote.copyWith(rating: rating) : withNote;
    });
  }

  Future<void> _updateAndSave(DiaryEntry Function(DiaryEntry current) update) async {
    await _ready;
    final current = state;
    if (current is! DiaryLoaded) return;

    final base =
        current.entry ??
        DiaryEntry(gameId: _gameId, status: PlayStatus.backlog, updatedAt: DateTime.now());
    final updated = update(base).copyWith(updatedAt: DateTime.now());

    emit(DiaryLoaded(updated, isSaving: true));
    final result = await _saveDiaryEntry(updated);
    switch (result) {
      case Ok():
        emit(DiaryLoaded(updated));
      case Err(:final failure):
        emit(DiaryLoaded(current.entry, error: failure.message));
    }
  }
}
