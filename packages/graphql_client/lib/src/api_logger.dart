import 'dart:developer' as developer;

class ApiLogger {
  final bool enabled;

  const ApiLogger({this.enabled = false});

  void request({
    required String operation,
    required String document,
    Map<String, dynamic>? variables,
  }) {
    if (!enabled) return;

    final summary = document.replaceAll(RegExp(r'\s+'), ' ').trim();
    developer.log(
      '→ $operation\n  query: $summary\n  variables: ${variables ?? {}}',
      name: 'API',
    );
  }

  void success({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? data,
  }) {
    if (!enabled) return;

    developer.log(
      '✓ $operation (${duration.inMilliseconds}ms)\n  keys: ${data?.keys.toList() ?? []}',
      name: 'API',
    );
  }

  void failure({
    required String operation,
    required Duration duration,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (!enabled) return;

    developer.log(
      '✗ $operation (${duration.inMilliseconds}ms)\n  error: $error',
      name: 'API',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
