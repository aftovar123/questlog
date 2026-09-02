import 'package:flutter/material.dart';
import 'package:questlog/app/router.dart';
import 'package:questlog/app/theme.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

class QuestlogApp extends StatelessWidget {
  const QuestlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Questlog',
      debugShowCheckedModeBanner: false,
      // Dark by default — the catalog art (posters, ratings) reads better
      // against a dark ground, same convention Letterboxd/Backloggd/Steam use.
      themeMode: ThemeMode.dark,
      theme: buildQuestlogTheme(Brightness.light),
      darkTheme: buildQuestlogTheme(Brightness.dark),
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
