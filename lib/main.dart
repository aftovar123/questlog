import 'package:flutter/material.dart';
import 'package:questlog/app/app.dart';
import 'package:questlog/app/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const QuestlogApp());
}
