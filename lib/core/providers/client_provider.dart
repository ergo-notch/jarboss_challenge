import 'package:flutter/foundation.dart';
import 'package:jarboss_challenge/core/core.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: Environment.baseUrl,
    enableLogging: kDebugMode,
  );
});
