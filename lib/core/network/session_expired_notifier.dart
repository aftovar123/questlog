import 'dart:async';

/// The one place that knows a request came back with an expired session —
/// nothing else. Deciding what to do about it (show a message, log the user
/// out, navigate to a login screen) is a presentation-layer concern, kept
/// out of `core/network` on purpose: this class only notifies, it never
/// touches a `BuildContext` or a router.
class SessionExpiredNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  void dispose() => _controller.close();
}
