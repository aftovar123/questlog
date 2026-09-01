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
      themeMode: ThemeMode.system,
      theme: buildQuestlogTheme(Brightness.light),
      darkTheme: buildQuestlogTheme(Brightness.dark),
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
