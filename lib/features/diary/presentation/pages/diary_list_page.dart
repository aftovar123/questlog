import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:questlog/app/injection.dart';
import 'package:questlog/core/widgets/fading_network_image.dart';
import 'package:questlog/features/diary/domain/usecases/delete_diary_entry.dart';
import 'package:questlog/features/diary/domain/usecases/get_all_diary_entries.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_list_cubit.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_list_state.dart';
import 'package:questlog/features/diary/presentation/widgets/diary_status_label.dart';
import 'package:questlog/features/games/domain/usecases/get_game_detail.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

/// Lists every game the player has marked in their diary, most recently
/// updated first — the piece that makes the diary feel like an actual log
/// instead of a detail scattered across individual game pages.
class DiaryListPage extends StatelessWidget {
  const DiaryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DiaryListCubit(getIt<GetAllDiaryEntries>(), getIt<GetGameDetail>(), getIt<DeleteDiaryEntry>()),
      child: const _DiaryListView(),
    );
  }
}

class _DiaryListView extends StatelessWidget {
  const _DiaryListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<DiaryListCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diaryTitle)),
      body: switch (state) {
        DiaryListLoading() => const Center(child: CircularProgressIndicator()),
        DiaryListEmpty() => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              l10n.myDiaryEmptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
        DiaryListFailed(:final message) => Center(
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
                  onPressed: () => context.read<DiaryListCubit>().load(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.retryLabel),
                ),
              ],
            ),
          ),
        ),
        DiaryListLoaded(:final items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _DiaryListTile(item: items[index]),
        ),
      },
    );
  }
}

class _DiaryListTile extends StatelessWidget {
  const _DiaryListTile({required this.item});

  final DiaryListItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final game = item.game;
    final entry = item.entry;

    return Dismissible(
      key: ValueKey(entry.gameId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.delete_rounded, color: scheme.onErrorContainer),
      ),
      confirmDismiss: (_) => _confirmAndDelete(context, l10n, game?.name ?? 'Juego #${entry.gameId}', entry.gameId),
      child: _DiaryTileCard(item: item),
    );
  }

  Future<bool> _confirmAndDelete(
    BuildContext context,
    AppLocalizations l10n,
    String gameName,
    int gameId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.diaryDeleteConfirmTitle),
        content: Text(l10n.diaryDeleteConfirmMessage(gameName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelLabel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.deleteLabel)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return false;

    final cubit = context.read<DiaryListCubit>();
    final deleted = await cubit.delete(gameId);
    if (!deleted && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.diaryDeleteErrorLabel)));
    }
    return deleted;
  }
}

class _DiaryTileCard extends StatelessWidget {
  const _DiaryTileCard({required this.item});

  final DiaryListItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final game = item.game;
    final entry = item.entry;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: game == null ? null : () => context.push('/games/${game.id}', extra: game),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 74,
                  child: FadingNetworkImage(imageUrl: game?.imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game?.name ?? 'Juego #${entry.gameId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            diaryStatusLabel(l10n, entry.status),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (entry.rating case final rating?) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('$rating/5', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ],
                    ),
                    if (entry.note case final note? when note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.diaryUpdatedLabel}: ${_formatDate(entry.updatedAt)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, fontSize: 11),
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

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
