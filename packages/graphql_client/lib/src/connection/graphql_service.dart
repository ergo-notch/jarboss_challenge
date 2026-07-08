import 'package:graphql_flutter/graphql_flutter.dart';

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

  GraphQLServiceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic>? variables,
  }) async {
    final result = await client.query(
      QueryOptions(document: gql(document), variables: variables ?? {}),
    );
    return _handleResult(result);
  }

  @override
  Future<Map<String, dynamic>> mutation(
    String document, {
    Map<String, dynamic>? variables,
  }) async {
    final result = await client.mutate(
      MutationOptions(document: gql(document), variables: variables ?? {}),
    );
    return _handleResult(result);
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
