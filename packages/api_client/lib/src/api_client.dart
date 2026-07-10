import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_exception.dart';

class ApiClient {
  final Dio _dio;
  final Duration _requestInterval;
  DateTime? _lastRequestAt;
  Future<void> _requestQueue = Future.value();

  ApiClient({
    required String baseUrl,
    bool enableLogging = false,
    Duration requestInterval = const Duration(seconds: 2),
    Dio? dio,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: const {'Content-Type': 'application/json'},
              ),
            ),
        _requestInterval = requestInterval {
    if (enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _execute(
      path: path,
      request: () => _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<dynamic> getData(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _execute(
      path: path,
      request: () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<T> _execute<T>({
    required String path,
    required Future<Response<T>> Function() request,
  }) async {
    return _throttle(() async {
      try {
        final response = await request();
        final data = response.data;

        if (data == null) {
          throw ApiException(
            type: ApiErrorType.emptyResponse,
            technicalMessage: 'No data returned from GET $path',
            statusCode: response.statusCode,
          );
        }

        return data;
      } on DioException catch (error) {
        throw _mapDioException(error, path);
      }
    });
  }

  Future<T> _throttle<T>(Future<T> Function() action) {
    final run = _requestQueue.then((_) async {
      if (_lastRequestAt != null) {
        final elapsed = DateTime.now().difference(_lastRequestAt!);
        final wait = _requestInterval - elapsed;
        if (wait > Duration.zero) {
          await Future<void>.delayed(wait);
        }
      }

      _lastRequestAt = DateTime.now();
      return action();
    });

    _requestQueue = run.then((_) {}, onError: (_) {});
    return run;
  }

  ApiException _mapDioException(DioException error, String path) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final apiMessage = _extractErrorMessage(responseData);

    final type = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ApiErrorType.timeout,
      DioExceptionType.connectionError => ApiErrorType.network,
      DioExceptionType.badResponse => _typeFromStatusCode(statusCode),
      _ => ApiErrorType.unknown,
    };

    return ApiException(
      type: type,
      statusCode: statusCode,
      technicalMessage: apiMessage ?? error.message ?? 'GET $path failed',
    );
  }

  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['error'] as String?;
    }
    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }
    return null;
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
}
