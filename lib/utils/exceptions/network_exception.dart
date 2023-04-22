class NetworkException implements Exception {
  final String message;
  final int statusCode;
  final String description;
  final Map<String, dynamic>? errors;

  NetworkException({
    required this.message,
    required this.statusCode,
    required this.description,
    this.errors,
  });

  @override
  String toString() {
    return 'NetworkException{message: $message, description: $description, statusCode: $statusCode,errors:$errors}';
  }
}
