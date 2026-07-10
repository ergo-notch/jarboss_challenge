import 'package:flutter/material.dart';
import 'package:jarboss_challenge/features/locations/domain/entities/location_entity.dart';

class LocationTile extends StatelessWidget {
  final LocationEntity location;

  const LocationTile({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.place, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          location.name ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          [
            if (location.type?.isNotEmpty == true) location.type,
            if (location.dimension?.isNotEmpty == true) location.dimension,
          ].join(' · '),
        ),
      ),
    );
  }
}
