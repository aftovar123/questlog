import 'package:go_router/go_router.dart';
import 'package:questlog/features/diary/presentation/pages/diary_list_page.dart';
import 'package:questlog/features/diary/presentation/pages/stats_page.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/presentation/pages/game_detail_page.dart';
import 'package:questlog/features/games/presentation/pages/games_list_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const GamesListPage()),
    GoRoute(path: '/diary', builder: (context, state) => const DiaryListPage()),
    GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
    GoRoute(
      path: '/games/:id',
      builder: (context, state) =>
          GameDetailPage(game: state.extra! as Game),
    ),
  ],
);
