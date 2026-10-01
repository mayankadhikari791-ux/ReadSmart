import 'network_exceptions.dart';

/// Status enum representing the lifecycle state of a data request.
enum ResourceStatus {
  initial,
  loading,
  success,
  error,
}

/// Generic wrapper encapsulating remote and local data operations.
///
/// Ensures the UI can always gracefully present loading indicators, error
/// messages (with cached data fallbacks), or success states without
/// having to inspect raw exception objects.
class Resource<T> {
  final ResourceStatus status;
  final T? data;
  final NetworkFailure? failure;
  final String? message;
  final bool isOffline;

  const Resource._({
    required this.status,
    this.data,
    this.failure,
    this.message,
    this.isOffline = false,
  });

  /// Factory for an uninitialized or idle state.
  factory Resource.initial([T? initialData]) => Resource._(
        status: ResourceStatus.initial,
        data: initialData,
      );

  /// Factory for an ongoing operation state.
  factory Resource.loading({String? message, T? previousData}) => Resource._(
        status: ResourceStatus.loading,
        data: previousData,
        message: message,
      );

  /// Factory for a successful operation.
  factory Resource.success(T data, {bool isOffline = false}) => Resource._(
        status: ResourceStatus.success,
        data: data,
        isOffline: isOffline,
      );

  /// Factory for a failed operation, optionally providing cached fallback data.
  factory Resource.error(
    NetworkFailure failure, {
    T? cachedData,
    bool isOffline = false,
  }) =>
      Resource._(
        status: ResourceStatus.error,
        failure: failure,
        message: failure.message,
        data: cachedData,
        isOffline: isOffline || failure is NoInternetFailure,
      );

  /// Convenience state checkers.
  bool get isInitial => status == ResourceStatus.initial;
  bool get isLoading => status == ResourceStatus.loading;
  bool get isSuccess => status == ResourceStatus.success;
  bool get isError => status == ResourceStatus.error;

  /// True if data is available (even in error or loading states when cached data exists).
  bool get hasData => data != null;

  /// Transforms the data using [transformer] if present.
  Resource<R> map<R>(R Function(T data) transformer) {
    return Resource<R>._(
      status: status,
      data: data != null ? transformer(data as T) : null,
      failure: failure,
      message: message,
      isOffline: isOffline,
    );
  }

  @override
  String toString() =>
      'Resource(status: $status, isOffline: $isOffline, hasData: $hasData, message: $message)';
}

