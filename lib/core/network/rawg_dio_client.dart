import 'package:dio/dio.dart';
import 'package:questlog/core/network/session_aware_error_interceptor.dart';
import 'package:questlog/core/network/session_expired_notifier.dart';

/// Pass the key at run time: `flutter run --dart-define=RAWG_API_KEY=xxxx`.
/// Never hardcode it — it must not end up committed to the repo.
const _rawgApiKey = String.fromEnvironment('RAWG_API_KEY');

Dio buildRawgDioClient(SessionExpiredNotifier sessionExpiredNotifier) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.rawg.io/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      queryParameters: {'key': _rawgApiKey},
    ),
  );

  // RAWG's public API has no real user session, so a 401 here only ever
  // means a missing/invalid key — but this is the exact hook a
  // session-aware API would use, wired the same way it would be for real.
  dio.interceptors.add(SessionAwareErrorInterceptor(sessionExpiredNotifier));

  return dio;
}
