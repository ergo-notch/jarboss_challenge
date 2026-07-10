import 'package:jarboss_challenge/features/details/data/models/details_model.dart';
import 'package:jarboss_challenge/features/details/data/models/episode_model.dart';

import '../../core.dart';

final dataSourceProvider = Provider<IDataSource>(
  (ref) => DataSourceImpl(client: ref.read(apiClientProvider)),
);

abstract class IDataSource {
  Future<CharactersListModel> getCharacters({
    num page = 1,
    String? name,
    CharacterStatus? filterStatus,
  });
  Future<DetailsModel> getCharacterDetails({String? characterId});
}

class DataSourceImpl implements IDataSource {
  final ApiClient client;

  DataSourceImpl({required this.client});

  @override
  Future<CharactersListModel> getCharacters({
    num page = 1,
    String? name,
    CharacterStatus? filterStatus,
  }) async {
    try {
      final result = await client.get(
        '/character',
        queryParameters: {
          'page': page,
          ...?_buildCharactersQuery(name: name, filterStatus: filterStatus),
        },
      );

      return CharactersListModel.fromJson(result);
    } on ApiException catch (error) {
      if (error.type == ApiErrorType.notFound) {
        return const CharactersListModel(count: 0, results: []);
      }
      rethrow;
    } catch (error, stackTrace) {
      throw GeneralException.parsing(error, context: stackTrace.toString());
    }
  }

  Map<String, dynamic>? _buildCharactersQuery({
    String? name,
    CharacterStatus? filterStatus,
  }) {
    final query = <String, dynamic>{};

    if (name != null && name.isNotEmpty) {
      query['name'] = name;
    }
    if (filterStatus != null) {
      query['status'] = filterStatus.apiFilterValue;
    }

    return query.isEmpty ? null : query;
  }

  @override
  Future<DetailsModel> getCharacterDetails({String? characterId}) async {
    try {
      final character = await client.get('/character/$characterId');
      final episodes = await _fetchEpisodes(
        character['episode'] as List<dynamic>?,
      );

      return DetailsModel.fromRestJson(character, episodes: episodes);
    } on ApiException {
      rethrow;
    } catch (error, stackTrace) {
      throw GeneralException.parsing(error, context: stackTrace.toString());
    }
  }

  Future<List<EpisodeModel>> _fetchEpisodes(List<dynamic>? episodeUrls) async {
    if (episodeUrls == null || episodeUrls.isEmpty) {
      return const [];
    }

    final ids = episodeUrls
        .map((url) => url.toString().split('/').last)
        .join(',');

    final response = await client.getData('/episode/$ids');
    final rawEpisodes = response is List<dynamic> ? response : [response];

    return List.unmodifiable(
      rawEpisodes.map(
        (item) => EpisodeModel.fromJson(item as Map<String, dynamic>),
      ),
    );
  }
}
