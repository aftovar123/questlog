import 'package:go_router/go_router.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/presentation/pages/game_detail_page.dart';
import 'package:questlog/features/games/presentation/pages/games_list_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const GamesListPage()),
    GoRoute(
      path: '/games/:id',
      builder: (context, state) =>
          GameDetailPage(game: state.extra! as Game),
    ),
  ],
);
