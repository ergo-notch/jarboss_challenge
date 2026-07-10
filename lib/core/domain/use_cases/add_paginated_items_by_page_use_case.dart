import 'package:jarboss_challenge/core/core.dart';

typedef PaginatedPageFetcher<TEntity> =
    Future<Either<AppException, PaginatedListEntity<TEntity>>> Function({
      required num page,
      String? name,
      String? filterValue,
    });

class AddPaginatedItemsByPageUseCase<TEntity>
    extends
        UseCase<
          AddPaginatedItemsByPageUseCaseResult<TEntity>,
          AddPaginatedItemsByPageUseCaseParams<TEntity>
        > {
  final PaginatedPageFetcher<TEntity> fetchPage;

  AddPaginatedItemsByPageUseCase({required this.fetchPage});

  @override
  Future<Either<AppException, AddPaginatedItemsByPageUseCaseResult<TEntity>>>
  call(AddPaginatedItemsByPageUseCaseParams<TEntity> params) async {
    if (params.isLastPage) {
      return Right(
        AddPaginatedItemsByPageUseCaseResult(
          isLastPage: true,
          result: PaginatedListEntity(
            count: params.items.length,
            results: params.items,
            next: null,
          ),
        ),
      );
    }

    final response = await fetchPage(
      page: params.page,
      name: params.name,
      filterValue: params.filterValue,
    );

    return response.fold((error) => Left(error), (success) {
      final results = List<TEntity>.unmodifiable([
        ...params.items,
        ...success.results ?? [],
      ]);

      return Right(
        AddPaginatedItemsByPageUseCaseResult(
          isLastPage: results.length >= (success.count ?? 0),
          result: PaginatedListEntity(
            count: success.count,
            results: results,
            next: success.next,
          ),
        ),
      );
    });
  }
}

class AddPaginatedItemsByPageUseCaseParams<TEntity> {
  final num page;
  final List<TEntity> items;
  final bool isLastPage;
  final String? name;
  final String? filterValue;

  AddPaginatedItemsByPageUseCaseParams({
    this.page = 1,
    List<TEntity>? items,
    this.isLastPage = false,
    this.name,
    this.filterValue,
  }) : items = items ?? List<TEntity>.empty(growable: false);
}

class AddPaginatedItemsByPageUseCaseResult<TEntity> {
  final bool isLastPage;
  final PaginatedListEntity<TEntity> result;

  const AddPaginatedItemsByPageUseCaseResult({
    this.isLastPage = false,
    required this.result,
  });
}
