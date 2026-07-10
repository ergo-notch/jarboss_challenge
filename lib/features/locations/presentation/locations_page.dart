import 'package:flutter/material.dart';
import 'package:jarboss_challenge/core/core.dart';
import 'package:jarboss_challenge/features/locations/presentation/providers/locations_view_model.dart';
import 'package:jarboss_challenge/features/locations/presentation/widgets/location_tile.dart';

class LocationsPage extends ConsumerWidget {
  static const String path = '/locations';
  static const String name = 'locations';

  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginatedListPage<LocationEntity, LocationsListNotifier>(
      listProvider: locationsViewModelProvider,
      title: 'Lugares',
      searchHintText: 'Buscar ubicación...',
      buildSuccessSlivers: (context, state, _) {
        return [
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return LocationTile(location: state.items[index]);
            }, childCount: state.items.length),
          ),
        ];
      },
    );
  }
}
