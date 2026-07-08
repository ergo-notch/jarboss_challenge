import 'package:jarboss_challenge/features/details/data/models/details_model.dart';

import '../../core.dart';

final dataSourceProvider = Provider<IDataSource>(
  (ref) => DataSourceImpl(client: ref.read(graphqlProvider)),
);

abstract class IDataSource {
  Future<CharactersListModel> getCharacters({
    num page = 1,
    String? name,
  });
  Future<DetailsModel> getCharacterDetails({String? characterId});
}

class DataSourceImpl implements IDataSource {
  final GraphQLService client;

  DataSourceImpl({required this.client});

  @override
  Future<CharactersListModel> getCharacters({
    num page = 1,
    String? name,
  }) async {
    try {
      final hasNameFilter = name != null && name.isNotEmpty;
      final result = await client.query(
        '''
        query GetCharacters(\$page: Int!, \$filter: FilterCharacter) {
          characters(page: \$page, filter: \$filter) {
            info {
              count
              next
              prev
            }
            results {
              id
              name
              status
              species
              image
            }
          }
        }''',
        variables: {
          'page': page,
          'filter': hasNameFilter ? {'name': name} : null,
        },
      );

      return CharactersListModel.fromJson(result);
    } on GraphQLErrorException catch (_) {
      rethrow;
    } catch (e) {
      throw GraphQLErrorException(message: 'Error fetching characters: $e');
    }
  }

  @override
  Future<DetailsModel> getCharacterDetails({String? characterId}) async {
    try {
      final result = await client.query('''
                    query {
                      character(id: $characterId) {
                            id
                            name
                            status
                            species
                            type
                            origin{
                                  name
                            }
                            location{
                                  name
                            }
                            image
                            episode{
                                  episode
                                  name
                            }
                      }
                      }''');

      return DetailsModel.fromJson(result);
    } on GraphQLErrorException catch (_) {
      rethrow;
    } catch (e) {
      throw GraphQLErrorException(
        message: 'Error fetching character details: $e',
      );
    }
  }
}
