import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questlog/app/injection.dart';
import 'package:questlog/features/diary/domain/entities/diary_stats.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';
import 'package:questlog/features/diary/presentation/cubit/stats_cubit.dart';
import 'package:questlog/features/diary/presentation/cubit/stats_state.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

/// A handful of numbers pulled live from the player's own diary — nothing
/// here is illustrative, so an empty diary just means an empty state.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatsCubit(getIt<GetAllDiaryEntries>(), getIt<GetGameDetail>()),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<StatsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: switch (state) {
        StatsLoading() => const Center(child: CircularProgressIndicator()),
        StatsEmpty() => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              l10n.statsEmptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
        StatsFailed(:final message) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 44, color: scheme.error),
                const SizedBox(height: 14),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.read<StatsCubit>().load(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.retryLabel),
                ),
              ],
            ),
          ),
        ),
        StatsLoaded(:final stats) => _StatsGrid(stats: stats),
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final DiaryStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final averageRatingValue = stats.averageRating;
    final topGenre = stats.topGenre;

    // A fixed aspect ratio made card height shrink together with width on
    // narrow phones, while the text inside (which can wrap to 2 lines)
    // stayed the same size — that combination overflowed on real devices.
    // Rows of stretched, content-sized cards can't overflow that way: each
    // row is exactly as tall as its tallest card needs to be, at any width
    // or text scale, and the whole thing scrolls if it still doesn't fit.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.bookmark_rounded,
                        label: l10n.statsTotalTrackedLabel,
                        value: '${stats.totalTracked}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _CompletedCard(
                        completed: stats.completedCount,
                        total: stats.totalTracked,
                        label: l10n.statsCompletedLabel,
                        fractionLabel: l10n.statsFractionLabel(stats.completedCount, stats.totalTracked),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _RatingCard(
                        rating: averageRatingValue,
                        label: l10n.statsAverageRatingLabel,
                        emptyLabel: l10n.statsAverageRatingEmptyLabel,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _GenreCard(
                        genre: topGenre,
                        count: stats.topGenreCount,
                        total: stats.totalTracked,
                        label: l10n.statsTopGenreLabel,
                        emptyLabel: l10n.statsTopGenreEmptyLabel,
                        fractionLabel: topGenre == null
                            ? null
                            : l10n.statsFractionLabel(stats.topGenreCount, stats.totalTracked),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: scheme.primary, size: 22),
          Text(value, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// A donut ring showing completed-vs-total at a glance, with the raw count
/// in its center — the same "4 de 6" the caption spells out below it.
class _CompletedCard extends StatelessWidget {
  const _CompletedCard({
    required this.completed,
    required this.total,
    required this.label,
    required this.fractionLabel,
  });

  final int completed;
  final int total;
  final String label;
  final String fractionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fraction = total == 0 ? 0.0 : completed / total;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: fraction,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: scheme.primary,
                ),
                Text('$completed', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold),
              ),
              Text(fractionLabel, style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Five stars where the rating fills them proportionally — not just full
/// stars snapped to the nearest integer, so 4.8 reads as 4 full stars plus
/// a mostly-full fifth one instead of rounding away the difference.
class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.rating, required this.label, required this.emptyLabel});

  final double? rating;
  final String label;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rating = this.rating;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.star_rounded, color: scheme.primary, size: 22),
          if (rating != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    children: [
                      TextSpan(text: rating.toStringAsFixed(1)),
                      TextSpan(
                        text: '/5',
                        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                _RatingStars(rating: rating),
              ],
            )
          else
            Text(emptyLabel, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          Text(label, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const starSize = 14.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Stack(
              children: [
                Icon(Icons.star_rounded, size: starSize, color: scheme.outlineVariant),
                ClipRect(
                  clipper: _FractionClipper((rating - i).clamp(0.0, 1.0)),
                  child: Icon(Icons.star_rounded, size: starSize, color: Colors.amber),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  const _FractionClipper(this.fraction);
  final double fraction;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_FractionClipper oldClipper) => oldClipper.fraction != fraction;
}

/// The favorite genre's share of the diary, as a filled bar instead of just
/// a bare count — "4 de 6" reads faster as roughly two-thirds of the bar lit.
class _GenreCard extends StatelessWidget {
  const _GenreCard({
    required this.genre,
    required this.count,
    required this.total,
    required this.label,
    required this.emptyLabel,
    required this.fractionLabel,
  });

  final String? genre;
  final int count;
  final int total;
  final String label;
  final String emptyLabel;
  final String? fractionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final genre = this.genre;
    final fraction = total == 0 ? 0.0 : count / total;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.local_fire_department_rounded, color: scheme.primary, size: 22),
          if (genre != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  genre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(fractionLabel!, style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 5,
                    backgroundColor: scheme.surfaceContainerHighest,
                    color: scheme.primary,
                  ),
                ),
              ],
            )
          else
            Text(emptyLabel, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          Text(label, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
