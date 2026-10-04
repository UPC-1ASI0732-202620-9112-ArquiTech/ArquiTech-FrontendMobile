class ApiError implements Exception {
  const ApiError({
    required this.code,
    required this.message,
    this.statusCode,
    this.timestamp,
    this.path,
  });

  final String code;
  final String message;
  final int? statusCode;
  final DateTime? timestamp;
  final String? path;

  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiError(
      code: json['code']?.toString() ?? 'INTERNAL_ERROR',
      message: json['message']?.toString() ?? 'Unexpected server error',
      statusCode: statusCode,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? ''),
      path: json['path']?.toString(),
    );
  }

  @override
  String toString() => 'ApiError($code, $statusCode)';
}
