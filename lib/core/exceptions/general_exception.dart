import 'package:api_client/api_client.dart';

enum GeneralErrorType {
  unexpected,
  parsing,
  mapping,
}

class GeneralException implements Exception, CustomException {
  final GeneralErrorType type;
  final String? technicalMessage;
  final Object? cause;

  const GeneralException({
    this.type = GeneralErrorType.unexpected,
    this.technicalMessage,
    this.cause,
  });

  factory GeneralException.unexpected(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    return GeneralException(
      type: GeneralErrorType.unexpected,
      technicalMessage: error.toString(),
      cause: error,
    );
  }

  factory GeneralException.parsing(
    Object error, {
    String? context,
  }) {
    return GeneralException(
      type: GeneralErrorType.parsing,
      technicalMessage: context ?? error.toString(),
      cause: error,
    );
  }

  @override
  String get title => switch (type) {
    GeneralErrorType.unexpected => 'Error inesperado',
    GeneralErrorType.parsing => 'Error al procesar datos',
    GeneralErrorType.mapping => 'Error al interpretar datos',
  };

  @override
  String get userMessage => switch (type) {
    GeneralErrorType.unexpected =>
      'Ocurrió un error inesperado. Intenta de nuevo.',
    GeneralErrorType.parsing =>
      'Recibimos una respuesta que no pudimos procesar. Intenta de nuevo.',
    GeneralErrorType.mapping =>
      'No pudimos mostrar la información correctamente. Intenta de nuevo.',
  };

  @override
  String toString() =>
      'GeneralException($type, message: $technicalMessage, cause: $cause)';
}
