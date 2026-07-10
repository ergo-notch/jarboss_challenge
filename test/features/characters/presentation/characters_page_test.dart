import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarboss_challenge/core/core.dart';
import 'package:jarboss_challenge/features/characters/domain/use_cases/add_characters_by_page_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockIRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AddCharactersByPageUseCaseParams());
  });

  setUp(() {
    mockRepository = MockIRepository();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        addCharactersByPageUseCaseProvider.overrideWithValue(
          AddCharactersByPageUseCase(repository: mockRepository),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const CharactersPage()),
    );
  }

  testWidgets('shows characters grid when data loads successfully', (
    tester,
  ) async {
    when(
      () => mockRepository.getCharacters(
        page: any(named: 'page'),
        name: any(named: 'name'),
        filterStatus: any(named: 'filterStatus'),
      ),
    ).thenAnswer((_) async => Right(charactersListEntity()));

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Morty Smith'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows empty state when API returns no characters', (
    tester,
  ) async {
    when(
      () => mockRepository.getCharacters(
        page: any(named: 'page'),
        name: any(named: 'name'),
        filterStatus: any(named: 'filterStatus'),
      ),
    ).thenAnswer(
      (_) async =>
          Right(charactersListEntity(count: 0, next: null, results: [])),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados'), findsOneWidget);
  });
}
