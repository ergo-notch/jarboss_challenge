import 'package:api_client/api_client.dart';

import 'general_exception.dart';

typedef AppException = CustomException;

AppException mapToAppException(Object error) {
  if (error is ApiException) return error;
  if (error is GeneralException) return error;
  return GeneralException.unexpected(error);
}
