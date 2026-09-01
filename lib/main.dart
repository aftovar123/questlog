import 'package:flutter/material.dart';
import 'package:questlog/app/app.dart';
import 'package:questlog/app/injection.dart';

void main() {
  configureDependencies();
  runApp(const QuestlogApp());
}
