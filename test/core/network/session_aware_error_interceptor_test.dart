import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:questlog/core/network/session_aware_error_interceptor.dart';
import 'package:questlog/core/network/session_expired_notifier.dart';

class _MockSessionExpiredNotifier extends Mock implements SessionExpiredNotifier {}

class _MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

DioException _errorWithStatus(int? statusCode, {DioExceptionType type = DioExceptionType.badResponse}) {
  final requestOptions = RequestOptions(path: '/games');
  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: statusCode == null
        ? null
        : Response(requestOptions: requestOptions, statusCode: statusCode),
  );
}

void main() {
  late _MockSessionExpiredNotifier notifier;
  late _MockErrorInterceptorHandler handler;
  late SessionAwareErrorInterceptor interceptor;

  setUp(() {
    notifier = _MockSessionExpiredNotifier();
    handler = _MockErrorInterceptorHandler();
    interceptor = SessionAwareErrorInterceptor(notifier);
  });

  test('notifies when the response is a 401', () {
    final error = _errorWithStatus(401);

    interceptor.onError(error, handler);

    verify(() => notifier.notify()).called(1);
    verify(() => handler.next(error)).called(1);
  });

  test('does not notify for other status codes', () {
    final error = _errorWithStatus(500);

    interceptor.onError(error, handler);

    verifyNever(() => notifier.notify());
    verify(() => handler.next(error)).called(1);
  });

  test('does not notify when there is no response at all, e.g. a timeout', () {
    final error = _errorWithStatus(null, type: DioExceptionType.connectionTimeout);

    interceptor.onError(error, handler);

    verifyNever(() => notifier.notify());
    verify(() => handler.next(error)).called(1);
  });
}
