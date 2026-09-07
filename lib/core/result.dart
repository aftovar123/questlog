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

/// A concrete stand-in for "no meaningful value" — `void` can't be used as
/// a generic type argument's actual value, so operations that only succeed
/// or fail (like saving to the diary) return `Result<Unit>` instead.
final class Unit {
  const Unit._();
  static const instance = Unit._();
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

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'No se pudo guardar en el dispositivo.']);
}
