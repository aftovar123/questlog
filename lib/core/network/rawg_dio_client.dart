import 'package:dio/dio.dart';

/// Pass the key at run time: `flutter run --dart-define=RAWG_API_KEY=xxxx`.
/// Never hardcode it — it must not end up committed to the repo.
const _rawgApiKey = String.fromEnvironment('RAWG_API_KEY');

Dio buildRawgDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.rawg.io/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      queryParameters: {'key': _rawgApiKey},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        // Punto único para futuros reintentos o refresco de sesión.
        handler.next(error);
      },
    ),
  );

  return dio;
}
