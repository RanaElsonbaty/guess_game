/// Base class for API failures.
class ApiFailure {
  final String message;
  final int? statusCode;

  const ApiFailure(this.message, {this.statusCode});

  List<Object?> get props => [message, statusCode];

  @override
  String toString() => 'ApiFailure(message: $message, statusCode: $statusCode)';
}


