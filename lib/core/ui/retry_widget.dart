import 'package:flutter/material.dart';

class RetryWidget extends StatelessWidget {
  final String errorMessage;
  final Function onRetry;

  const RetryWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => onRetry(),
            label: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: const Icon(Icons.refresh, size: 35, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}
