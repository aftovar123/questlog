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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _StatCard(
              icon: Icons.bookmark_rounded,
              label: l10n.statsTotalTrackedLabel,
              value: '${stats.totalTracked}',
            ),
            _StatCard(
              icon: Icons.check_circle_rounded,
              label: l10n.statsCompletedLabel,
              value: '${stats.completedCount}',
            ),
            _StatCard(
              icon: Icons.star_rounded,
              label: l10n.statsAverageRatingLabel,
              value: averageRatingValue == null
                  ? null
                  : '${averageRatingValue.toStringAsFixed(1)}/5',
              emptyLabel: l10n.statsAverageRatingEmptyLabel,
            ),
            _StatCard(
              icon: Icons.local_fire_department_rounded,
              label: l10n.statsTopGenreLabel,
              value: topGenre,
              caption: topGenre == null ? null : l10n.statsTopGenreCountLabel(stats.topGenreCount),
              emptyLabel: l10n.statsTopGenreEmptyLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.emptyLabel,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String? caption;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: scheme.primary, size: 22),
            if (value != null) ...[
              Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (caption != null)
                Text(caption!, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ] else
              Text(
                emptyLabel ?? '',
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            Text(label, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
