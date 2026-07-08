import 'package:go_router/go_router.dart';
import 'package:jarboss_challenge/splash_screen.dart';

import '../features/characters/characters.dart';
import '../features/details/details.dart';

final router = GoRouter(
  initialLocation: SplashScreen.path,
  routes: [
    GoRoute(
      path: SplashScreen.path,
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: CharactersPage.path,
      name: CharactersPage.name,
      builder: (context, state) => CharactersPage(),
      routes: [
        GoRoute(
          path: 'character/:id',
          name: 'characterDetail',
          builder: (context, state) {
            final id = state.pathParameters['id'];
            return CharacterDetailsPage(characterId: id ?? '');
          },
        ),
      ],
    ),
  ],
);
