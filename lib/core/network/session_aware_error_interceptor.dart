import 'package:dio/dio.dart';
import 'package:questlog/core/network/session_expired_notifier.dart';

/// Detects an expired session (HTTP 401) and reports it — that's the whole
/// job. It never redirects, never shows UI, and always forwards the error
/// unchanged via `handler.next`, so the existing repository error-mapping
/// still runs exactly as before. Written as its own [Interceptor] subclass
/// (instead of an inline `InterceptorsWrapper` closure) specifically so this
/// detection logic can be unit-tested without spinning up real HTTP calls.
class SessionAwareErrorInterceptor extends Interceptor {
  SessionAwareErrorInterceptor(this._notifier);
  final SessionExpiredNotifier _notifier;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _notifier.notify();
    }
    handler.next(err);
  }
}
