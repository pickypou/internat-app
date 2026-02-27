/// Base class for custom application errors.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Represents an error occurring on the server side (e.g. Supabase).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
