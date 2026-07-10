import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';

class RetryWidget extends StatelessWidget {
  final CustomException error;
  final VoidCallback onRetry;

  const RetryWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  IconData get _icon => switch (error) {
    ApiException(type: ApiErrorType.network) => Icons.wifi_off_rounded,
    ApiException(type: ApiErrorType.timeout) => Icons.timer_off_rounded,
    ApiException(type: ApiErrorType.rateLimited) => Icons.speed_rounded,
    ApiException(type: ApiErrorType.notFound) => Icons.search_off_rounded,
    ApiException(type: ApiErrorType.serverError) => Icons.cloud_off_rounded,
    ApiException() => Icons.cloud_off_rounded,
    _ => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 56, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              error.title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.userMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
