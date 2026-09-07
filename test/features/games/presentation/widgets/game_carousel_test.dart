import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/features/games/domain/entities/game.dart';
import 'package:questlog/features/games/presentation/widgets/game_carousel.dart';
import 'package:questlog/features/games/presentation/widgets/game_grid_item.dart';

// imageUrl: null on purpose — FadingNetworkImage skips Image.network entirely
// for a null url, so these widget tests never touch the real network.
Game _game(int id) => Game(id: id, name: 'Game $id', imageUrl: null, rating: 4.0);

Future<void> _pump(WidgetTester tester, GameCarousel carousel) {
  return tester.pumpWidget(MaterialApp(home: Scaffold(body: carousel)));
}

void main() {
  testWidgets('renders one GameGridItem per game', (tester) async {
    await _pump(tester, GameCarousel(games: [_game(1), _game(2), _game(3)], onLoadMore: () {}));

    expect(find.byType(GameGridItem), findsNWidgets(3));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows a trailing spinner while isLoadingMore is true', (tester) async {
    await _pump(
      tester,
      GameCarousel(
        games: [_game(1), _game(2)],
        onLoadMore: () {},
        hasMore: true,
        isLoadingMore: true,
      ),
    );

    expect(find.byType(GameGridItem), findsNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('calls onLoadMore once the scroll gets near the end', (tester) async {
    var loadMoreCalls = 0;
    final games = List.generate(20, _game);

    await _pump(
      tester,
      GameCarousel(games: games, hasMore: true, onLoadMore: () => loadMoreCalls++),
    );

    await tester.drag(find.byType(ListView), const Offset(-5000, 0));
    await tester.pump();

    expect(loadMoreCalls, greaterThan(0));
  });

  testWidgets('does not call onLoadMore when hasMore is false', (tester) async {
    var loadMoreCalls = 0;
    final games = List.generate(20, _game);

    // hasMore defaults to false — the same drag that triggers a load in the
    // test above should be a no-op here.
    await _pump(tester, GameCarousel(games: games, onLoadMore: () => loadMoreCalls++));

    await tester.drag(find.byType(ListView), const Offset(-5000, 0));
    await tester.pump();

    expect(loadMoreCalls, 0);
  });
}
