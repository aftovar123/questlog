import 'dart:async';

import 'package:flutter/material.dart';
import 'package:questlog/app/injection.dart';
import 'package:questlog/app/router.dart';
import 'package:questlog/app/theme.dart';
import 'package:questlog/core/network/session_expired_notifier.dart';
import 'package:questlog/l10n/generated/app_localizations.dart';

class QuestlogApp extends StatefulWidget {
  const QuestlogApp({super.key});

  @override
  State<QuestlogApp> createState() => _QuestlogAppState();
}

class _QuestlogAppState extends State<QuestlogApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final StreamSubscription<void> _sessionExpiredSubscription;

  @override
  void initState() {
    super.initState();
    // The interceptor only detects a 401 and reports it here — showing this
    // message is the "decide what to do about it" half, kept in the app
    // shell instead of `core/network` or any repository.
    _sessionExpiredSubscription = getIt<SessionExpiredNotifier>().stream.listen((_) {
      if (!mounted) return;
      final context = _scaffoldMessengerKey.currentContext;
      if (context == null) return;
      // The lint assumes a captured, possibly-stale BuildContext; this one is
      // looked up fresh (via the GlobalKey) at the moment the event fires and
      // guarded by `mounted` just above, so it's safe.
      // ignore: use_build_context_synchronously
      final l10n = AppLocalizations.of(context)!;
      _scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.sessionExpiredMessage)));
    });
  }

  @override
  void dispose() {
    _sessionExpiredSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Questlog',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
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
