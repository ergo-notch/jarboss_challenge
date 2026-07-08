import 'package:graphql_flutter/graphql_flutter.dart';

import '../api_logger.dart';
import '../graphql_exception.dart';

abstract class GraphQLService {
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic>? variables,
  });

  Future<Map<String, dynamic>> mutation(
    String document, {
    Map<String, dynamic>? variables,
  });
}

class GraphQLServiceImpl implements GraphQLService {
  final GraphQLClient client;
  final ApiLogger logger;

  GraphQLServiceImpl({
    required this.client,
    ApiLogger? logger,
  }) : logger = logger ?? const ApiLogger();

  @override
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic>? variables,
  }) async {
    return _execute(
      operation: 'QUERY',
      document: document,
      variables: variables,
      execute: () => client.query(
        QueryOptions(document: gql(document), variables: variables ?? {}),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> mutation(
    String document, {
    Map<String, dynamic>? variables,
  }) async {
    return _execute(
      operation: 'MUTATION',
      document: document,
      variables: variables,
      execute: () => client.mutate(
        MutationOptions(document: gql(document), variables: variables ?? {}),
      ),
    );
  }

  Future<Map<String, dynamic>> _execute({
    required String operation,
    required String document,
    required Map<String, dynamic>? variables,
    required Future<QueryResult> Function() execute,
  }) async {
    final stopwatch = Stopwatch()..start();

    logger.request(
      operation: operation,
      document: document,
      variables: variables,
    );

    try {
      final result = await execute();
      final data = _handleResult(result);
      stopwatch.stop();

      logger.success(
        operation: operation,
        duration: stopwatch.elapsed,
        data: data,
      );

      return data;
    } on GraphQLErrorException catch (error, stackTrace) {
      stopwatch.stop();
      logger.failure(
        operation: operation,
        duration: stopwatch.elapsed,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      stopwatch.stop();
      logger.failure(
        operation: operation,
        duration: stopwatch.elapsed,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Map<String, dynamic> _handleResult(QueryResult result) {
    if (result.hasException) {
      final gqlErrors =
          result.exception?.graphqlErrors.map((e) => e.message).toList();
      final networkError = result.exception?.linkException;

      throw GraphQLErrorException(
        message:
            gqlErrors?.join('; ') ??
            networkError?.toString() ??
            'Unknown GraphQL error',
        graphqlErrors: gqlErrors,
      );
    }

    final data = result.data;
    if (data == null) {
      throw GraphQLErrorException(
        message: 'No data returned from GraphQL server',
      );
    }

    return data;
  }
}
