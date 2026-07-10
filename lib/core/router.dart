import 'package:go_router/go_router.dart';
import 'package:jarboss_challenge/core/presentation/main_shell_page.dart';
import 'package:jarboss_challenge/splash_screen.dart';

import '../features/characters/characters.dart';
import '../features/details/details.dart';
import '../features/episodes/episodes.dart';
import '../features/locations/locations.dart';

final router = GoRouter(
  initialLocation: SplashScreen.path,
  routes: [
    GoRoute(
      path: SplashScreen.path,
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellPage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: CharactersPage.path,
              name: CharactersPage.name,
              builder: (context, state) => const CharactersPage(),
              routes: [
                GoRoute(
                  path: 'character/:id',
                  name: 'characterDetail',
                  builder: (context, state) {
                    final id = state.pathParameters['id'];
                    final character = state.extra as CharacterEntity?;
                    return CharacterDetailsPage(
                      characterId: id ?? '',
                      character: character,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: EpisodesPage.path,
              name: EpisodesPage.name,
              builder: (context, state) => const EpisodesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: LocationsPage.path,
              name: LocationsPage.name,
              builder: (context, state) => const LocationsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
