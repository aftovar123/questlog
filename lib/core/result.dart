/// Represents the outcome of an operation that can fail: either a success
/// carrying [T], or a failure. Consumers switch on this instead of relying on
/// exceptions crossing into the UI layer.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No se pudo conectar. Revisa tu internet.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor. Intenta más tarde.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.']);
}
