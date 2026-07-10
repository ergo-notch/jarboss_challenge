import 'custom_exception.dart';

enum ApiErrorType {
  network,
  timeout,
  notFound,
  clientError,
  serverError,
  rateLimited,
  emptyResponse,
  unknown,
}

class ApiException implements Exception, CustomException {
  final ApiErrorType type;
  final String? technicalMessage;
  final int? statusCode;

  ApiException({
    required this.type,
    this.technicalMessage,
    this.statusCode,
  });

  factory ApiException.fromStatusCode({
    required int? statusCode,
    String? technicalMessage,
  }) {
    return ApiException(
      type: _typeFromStatusCode(statusCode),
      statusCode: statusCode,
      technicalMessage: technicalMessage,
    );
  }

  static ApiErrorType _typeFromStatusCode(int? statusCode) {
    return switch (statusCode) {
      404 => ApiErrorType.notFound,
      429 => ApiErrorType.rateLimited,
      final code? when code >= 500 && code < 600 => ApiErrorType.serverError,
      final code? when code >= 400 && code < 500 => ApiErrorType.clientError,
      _ => ApiErrorType.unknown,
    };
  }

  @override
  String get title => switch (type) {
    ApiErrorType.network => 'Sin conexión',
    ApiErrorType.timeout => 'Tiempo agotado',
    ApiErrorType.notFound => 'No encontrado',
    ApiErrorType.clientError => 'Solicitud inválida',
    ApiErrorType.serverError => 'Servidor no disponible',
    ApiErrorType.rateLimited => 'Demasiadas solicitudes',
    ApiErrorType.emptyResponse => 'Respuesta vacía',
    ApiErrorType.unknown => 'Error de API',
  };

  @override
  String get userMessage => switch (type) {
    ApiErrorType.network =>
      'No pudimos conectar con el servidor. Revisa tu conexión a internet.',
    ApiErrorType.timeout =>
      'La solicitud tardó demasiado. Intenta de nuevo en unos segundos.',
    ApiErrorType.notFound =>
      'No encontramos la información solicitada.',
    ApiErrorType.clientError =>
      'La solicitud no pudo procesarse. Verifica los datos e intenta de nuevo.',
    ApiErrorType.serverError =>
      'El servidor no está disponible en este momento. Intenta más tarde.',
    ApiErrorType.rateLimited =>
      'Hiciste demasiadas solicitudes seguidas. Espera un momento y reintenta.',
    ApiErrorType.emptyResponse =>
      'El servidor respondió sin datos. Intenta de nuevo.',
    ApiErrorType.unknown =>
      'Ocurrió un problema al comunicarnos con el servidor.',
  };

  @override
  String toString() =>
      'ApiException($type, statusCode: $statusCode, message: $technicalMessage)';
}
