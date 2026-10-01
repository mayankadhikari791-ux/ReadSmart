/// Universal base failure representation for backend and local network errors.
abstract class NetworkFailure implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const NetworkFailure(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() =>
      'NetworkFailure(message: $message, statusCode: $statusCode)';
}

/// Thrown or returned when there is no internet connection or DNS resolution fails.
class NoInternetFailure extends NetworkFailure {
  const NoInternetFailure([
    String message = 'No internet connection. Operating in offline mode.',
  ]) : super(message);
}

/// Thrown or returned when a request takes longer than the allotted timeout duration.
class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure([
    String message = 'The server request timed out. Please check your network and try again.',
  ]) : super(message, statusCode: 408);
}

/// Thrown or returned when authentication token is missing, expired, or invalid.
class UnauthorizedFailure extends NetworkFailure {
  const UnauthorizedFailure([
    String message = 'Unauthorized session. Please sign in again to continue.',
  ]) : super(message, statusCode: 401);
}

/// Thrown or returned when an internal server or 5xx error occurs on the backend.
class ServerFailure extends NetworkFailure {
  const ServerFailure(
    String message, {
    int? statusCode,
    dynamic originalError,
  }) : super(message, statusCode: statusCode ?? 500, originalError: originalError);
}

/// Thrown or returned when payload deserialization, parsing, or validation fails.
class InvalidDataFailure extends NetworkFailure {
  const InvalidDataFailure([
    String message = 'Received invalid or corrupted data format from server.',
  ]) : super(message, statusCode: 422);
}

/// General unexpected client or platform failure.
class UnknownFailure extends NetworkFailure {
  const UnknownFailure([
    String message = 'An unexpected error occurred. Please try again.',
    dynamic originalError,
  ]) : super(message, originalError: originalError);
}

