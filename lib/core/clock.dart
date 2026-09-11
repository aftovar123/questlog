/// A seam around "what time is it right now". Anything that needs the
/// current time takes this instead of calling `DateTime.now()` directly, so
/// a test can hand it a fixed instant instead of asserting loosely (or
/// waiting on real time) around whatever `DateTime.now()` happened to
/// return when the test ran.
abstract class Clock {
  DateTime now();
}

/// The real clock, used everywhere outside of tests.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
