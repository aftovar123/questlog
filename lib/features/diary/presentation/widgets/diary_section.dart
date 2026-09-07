import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/app/theme.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_state.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

/// The "Letterboxd" part of Questlog — status, rating and a personal note,
/// all local to this device via Hive. Lives on the game detail page.
class DiarySection extends StatelessWidget {
  const DiarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<DiaryCubit>().state;

    if (state is DiaryLoading) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final loaded = state as DiaryLoaded;
    final status = loaded.entry?.status ?? PlayStatus.backlog;
    final rating = loaded.entry?.rating ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.diaryTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              if (loaded.isSaving)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
                )
              else if (loaded.entry != null)
                Icon(Icons.check_circle_rounded, size: 16, color: RatingColors.great),
            ],
          ),
          if (loaded.error != null) ...[
            const SizedBox(height: 4),
            Text(loaded.error!, style: TextStyle(color: scheme.error, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in PlayStatus.values)
                ChoiceChip(
                  label: Text(_statusLabel(l10n, option)),
                  selected: status == option,
                  onSelected: (_) => context.read<DiaryCubit>().updateStatus(option),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.diaryRatingLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          Row(
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => context.read<DiaryCubit>().updateRating(star),
                  icon: Icon(
                    star <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: star <= rating ? Colors.amber : scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _NoteField(
            initialNote: loaded.entry?.note,
            hint: l10n.diaryNoteHint,
            saveLabel: l10n.diarySaveNoteLabel,
            onSave: (text) => context.read<DiaryCubit>().updateNote(text),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, PlayStatus status) {
    return switch (status) {
      PlayStatus.backlog => l10n.diaryStatusBacklog,
      PlayStatus.playing => l10n.diaryStatusPlaying,
      PlayStatus.completed => l10n.diaryStatusCompleted,
    };
  }
}

class _NoteField extends StatefulWidget {
  const _NoteField({
    required this.initialNote,
    required this.hint,
    required this.saveLabel,
    required this.onSave,
  });

  final String? initialNote;
  final String hint;
  final String saveLabel;
  final ValueChanged<String> onSave;

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  // `late final` on purpose: this widget stays mounted at the same tree
  // position across DiaryCubit rebuilds, so re-reading initialNote on every
  // build would stomp on text the player is still typing.
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialNote ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(hintText: widget.hint),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => widget.onSave(_controller.text),
            child: Text(widget.saveLabel),
          ),
        ),
      ],
    );
  }
}
