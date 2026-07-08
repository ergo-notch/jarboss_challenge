class GraphQLErrorException implements Exception {
  final String message;
  final int? statusCode;
  final List<String>? graphqlErrors;

  GraphQLErrorException({
    required this.message,
    this.statusCode,
    this.graphqlErrors,
  });

  @override
  String toString() {
    return 'GraphQLErrorException: $message';
  }
}
