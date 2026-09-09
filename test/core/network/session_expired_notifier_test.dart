import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/network/session_expired_notifier.dart';

void main() {
  test('notify() emits an event on the stream', () {
    final notifier = SessionExpiredNotifier();
    addTearDown(notifier.dispose);

    expectLater(notifier.stream, emits(null));

    notifier.notify();
  });

  test('stream is broadcast, so multiple listeners all get notified', () {
    final notifier = SessionExpiredNotifier();
    addTearDown(notifier.dispose);

    expectLater(notifier.stream, emits(null));
    expectLater(notifier.stream, emits(null));

    notifier.notify();
  });
}
