import 'package:flutter/material.dart';
import 'package:questlog/app/router.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

class QuestlogApp extends StatelessWidget {
  const QuestlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Questlog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
