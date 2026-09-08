import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/features/diary/domain/entities/diary_entry.dart';
import 'package:questlog/features/diary/domain/entities/play_status.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:questlog/features/diary/presentation/cubit/diary_state.dart';
import 'package:questlog/features/diary/presentation/widgets/diary_section.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';
import 'package:questlog/l10n/generated/app_localizations_en.dart';

class _MockDiaryCubit extends MockCubit<DiaryState> implements DiaryCubit {}

Future<void> _pump(WidgetTester tester, DiaryCubit cubit) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: BlocProvider<DiaryCubit>.value(value: cubit, child: const DiarySection())),
    ),
  );
}

void main() {
  late _MockDiaryCubit cubit;
  final l10n = AppLocalizationsEn();

  setUpAll(() {
    registerFallbackValue(PlayStatus.backlog);
  });

  setUp(() {
    cubit = _MockDiaryCubit();
  });

  testWidgets('shows a loading indicator while the cubit is still loading', (tester) async {
    whenListen(cubit, const Stream<DiaryState>.empty(), initialState: const DiaryLoading());

    await _pump(tester, cubit);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('with no saved entry, starts in edit mode with Backlog selected and no stars filled', (
    tester,
  ) async {
    whenListen(cubit, const Stream<DiaryState>.empty(), initialState: const DiaryLoaded(null));

    await _pump(tester, cubit);

    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
    expect(chips.map((c) => c.selected), [true, false, false]);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(5));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(l10n.diarySaveReviewLabel), findsOneWidget);
  });

  testWidgets('reflects a saved status and shows the review in read-only view mode', (tester) async {
    final entry = DiaryEntry(
      gameId: 1,
      status: PlayStatus.playing,
      rating: 3,
      note: 'Great combat',
      updatedAt: DateTime(2026, 1, 1),
    );
    whenListen(cubit, const Stream<DiaryState>.empty(), initialState: DiaryLoaded(entry));

    await _pump(tester, cubit);

    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
    expect(chips.map((c) => c.selected), [false, true, false]);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(2));
    expect(find.text('Great combat'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text(l10n.diaryEditReviewLabel), findsOneWidget);
  });

  testWidgets('shows the error message when the state carries one', (tester) async {
    whenListen(
      cubit,
      const Stream<DiaryState>.empty(),
      initialState: const DiaryLoaded(null, error: 'No se pudo guardar en el dispositivo.'),
    );

    await _pump(tester, cubit);

    expect(find.text('No se pudo guardar en el dispositivo.'), findsOneWidget);
  });

  testWidgets('tapping a status chip calls updateStatus with that status', (tester) async {
    whenListen(cubit, const Stream<DiaryState>.empty(), initialState: const DiaryLoaded(null));
    when(() => cubit.updateStatus(any())).thenAnswer((_) async {});

    await _pump(tester, cubit);
    await tester.tap(find.byType(ChoiceChip).at(2)); // Completado

    verify(() => cubit.updateStatus(PlayStatus.completed)).called(1);
  });

  testWidgets('tapping a star only updates the draft rating, without saving', (tester) async {
    whenListen(cubit, const Stream<DiaryState>.empty(), initialState: const DiaryLoaded(null));

    await _pump(tester, cubit);
    await tester.tap(find.byType(IconButton).at(2)); // third star = rating 3
    await tester.pump();

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    verifyNever(() => cubit.saveReview(rating: any(named: 'rating'), note: any(named: 'note')));
  });

  testWidgets('tapping a star while viewing a saved review switches back to edit mode', (tester) async {
    final entry = DiaryEntry(gameId: 1, status: PlayStatus.playing, rating: 3, note: 'ok', updatedAt: DateTime(2026, 1, 1));
    whenListen(cubit, const Stream<DiaryState>.empty(), initialState: DiaryLoaded(entry));

    await _pump(tester, cubit);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byType(IconButton).at(4)); // fifth star = rating 5
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(l10n.diarySaveReviewLabel), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
  });

  testWidgets('tapping Edit on a saved review switches to edit mode with the note prefilled', (tester) async {
    final entry = DiaryEntry(gameId: 1, status: PlayStatus.playing, rating: 3, note: 'Great combat', updatedAt: DateTime(2026, 1, 1));
    whenListen(cubit, const Stream<DiaryState>.empty(), initialState: DiaryLoaded(entry));

    await _pump(tester, cubit);
    await tester.tap(find.text(l10n.diaryEditReviewLabel));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Great combat'), findsOneWidget);
  });

  testWidgets('tapping Save review saves the draft rating and note together, in one call', (tester) async {
    whenListen(cubit, const Stream<DiaryState>.empty(), initialState: const DiaryLoaded(null));
    when(() => cubit.saveReview(rating: any(named: 'rating'), note: any(named: 'note'))).thenAnswer((_) async {});

    await _pump(tester, cubit);
    await tester.tap(find.byType(IconButton).at(3)); // fourth star = rating 4
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Great game');
    await tester.tap(find.text(l10n.diarySaveReviewLabel));

    verify(() => cubit.saveReview(rating: 4, note: 'Great game')).called(1);
  });

  testWidgets('shows a confirmation snackbar once a save finishes successfully', (tester) async {
    final controller = StreamController<DiaryState>();
    addTearDown(controller.close);
    whenListen(cubit, controller.stream, initialState: const DiaryLoaded(null, isSaving: true));

    await _pump(tester, cubit);
    controller.add(const DiaryLoaded(null));
    await tester.pump();

    expect(find.text(l10n.diarySavedLabel), findsOneWidget);
  });

  testWidgets('does not show a confirmation snackbar when the save fails', (tester) async {
    final controller = StreamController<DiaryState>();
    addTearDown(controller.close);
    whenListen(cubit, controller.stream, initialState: const DiaryLoaded(null, isSaving: true));

    await _pump(tester, cubit);
    controller.add(const DiaryLoaded(null, error: 'boom'));
    await tester.pump();

    expect(find.text(l10n.diarySavedLabel), findsNothing);
  });
}
