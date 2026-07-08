import 'package:jarboss_challenge/core/core.dart';

final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  return GraphQLClient(
    link: HttpLink(Environment.baseUrl),
    cache: GraphQLCache(),
  );
});

final graphqlProvider = Provider<GraphQLService>((ref) {
  final client = ref.read(graphqlClientProvider);
  return GraphQLServiceImpl(client: client);
});
