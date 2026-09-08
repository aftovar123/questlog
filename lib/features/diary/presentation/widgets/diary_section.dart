import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/app/theme.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_state.dart';
import 'package:questlog/features/diary/presentation/widgets/diary_status_label.dart';
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

    return BlocListener<DiaryCubit, DiaryState>(
      // A save just finished successfully (was saving, now isn't, no error)
      // — confirm it with a snackbar instead of relying only on the small
      // checkmark next to the title, which is easy to miss.
      listenWhen: (previous, current) =>
          previous is DiaryLoaded &&
          previous.isSaving &&
          current is DiaryLoaded &&
          !current.isSaving &&
          current.error == null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.diarySavedLabel), duration: const Duration(seconds: 2)));
      },
      child: _buildCard(context, l10n, scheme, state),
    );
  }

  Widget _buildCard(BuildContext context, AppLocalizations l10n, ColorScheme scheme, DiaryState state) {
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
              Icon(Icons.bookmark_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
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
                  label: Text(diaryStatusLabel(l10n, option)),
                  selected: status == option,
                  onSelected: (_) => context.read<DiaryCubit>().updateStatus(option),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _ReviewBlock(
            initialRating: loaded.entry?.rating ?? 0,
            initialNote: loaded.entry?.note,
            isSaving: loaded.isSaving,
            onSave: (rating, note) => context.read<DiaryCubit>().saveReview(rating: rating, note: note),
          ),
        ],
      ),
    );
  }
}

/// Rating and note as a single unit: one "Save review" action instead of an
/// instant save (and a confirmation) per star tap. Once a review exists, it
/// renders as a read-only, distinctly-colored block with an "Edit" button —
/// tapping either that button or a star switches back into edit mode.
class _ReviewBlock extends StatefulWidget {
  const _ReviewBlock({
    required this.initialRating,
    required this.initialNote,
    required this.isSaving,
    required this.onSave,
  });

  final int initialRating;
  final String? initialNote;
  final bool isSaving;
  final Future<void> Function(int rating, String note) onSave;

  @override
  State<_ReviewBlock> createState() => _ReviewBlockState();
}

class _ReviewBlockState extends State<_ReviewBlock> {
  // Initialized once from the widget, then mutated locally via setState —
  // same reasoning as the controller below: re-reading widget.initialRating
  // on every DiaryCubit rebuild would undo a star tap made before saving.
  late int _draftRating = widget.initialRating;
  late final TextEditingController _controller = TextEditingController(text: widget.initialNote ?? '');
  late bool _editing = widget.initialRating == 0 && (widget.initialNote == null || widget.initialNote!.isEmpty);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enterEditMode(int? tappedStar) {
    setState(() {
      _editing = true;
      if (tappedStar != null) _draftRating = tappedStar;
    });
  }

  Future<void> _save() async {
    await widget.onSave(_draftRating, _controller.text);
    if (mounted) setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.diaryRatingLabel,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        Row(
          children: [
            for (var star = 1; star <= 5; star++)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _enterEditMode(star),
                icon: Icon(
                  star <= _draftRating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: star <= _draftRating ? Colors.amber : scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_editing) ...[
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(hintText: l10n.diaryNoteHint),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isSaving ? null : _save,
              child: Text(l10n.diarySaveReviewLabel),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _controller.text.isEmpty ? l10n.diaryNoteHint : _controller.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontStyle: _controller.text.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _enterEditMode(null),
              child: Text(l10n.diaryEditReviewLabel),
            ),
          ),
        ],
      ],
    );
  }
}
