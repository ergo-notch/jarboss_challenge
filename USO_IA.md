# USO_IA.md — AI Usage in Jarboss Challenge

This document describes how AI (Cursor / Claude) was used during development: what was delegated, structured prompts that worked well, and cases where generated code was **reviewed, corrected, or rejected**.

---

## Project overview

- **Challenge:** Project 1 — Rick & Morty Character Explorer (REST API).
- **Stack:** Flutter, Clean Architecture, Riverpod, go_router, Dio (`packages/api_client`).
- **Scope beyond baseline:** generic paginated lists for episodes and locations, bottom navigation shell.

---

## AI usage strategies

| Strategy | Description | When to use |
|----------|-------------|-------------|
| **Scaffold + wire end-to-end** | Request a reusable widget plus full stack integration (UI → ViewModel → UseCase → Repository → DataSource). | New features: search, filters, pagination. |
| **Architecture review before accepting** | Validate whether a pattern fits the use case (debounce vs throttle vs pagination lock). | Rate limiting, infinite scroll, 429 handling. |
| **Generic refactor with tests** | Extract duplicated logic into `core/` and update existing tests. | Episodes, locations, `PaginatedListPage`. |

---

## 1. Generic paginated list (`PaginatedListPage`)

### Prompt used

```markdown
Refactor the characters list screen into a reusable generic component for locations and episodes.

Constraints:
- Keep the existing Clean Architecture + Riverpod setup — extend it, don't replace it.
- Move shared pagination state/viewmodel/use case into `core/`.
- Add `getLocations()` and `getEpisodes()` to IDataSource and IRepository following the same Either + ApiException pattern as characters.
- Wire new features under `lib/features/locations/` and `lib/features/episodes/` with the same layer structure (model, entity, use case, page, tile).
- Bottom navigation with 3 tabs: Characters, Episodes, Locations.
- REST endpoints: GET /location?page=&name= and GET /episode?page=&name= per Rick & Morty API docs.
```

### What was delegated

- `PaginatedListModel`, `PaginatedListEntity`, `PaginatedListState`, `PaginatedListViewModel`.
- `AddPaginatedItemsByPageUseCase<T>` with a `fetchPage` callback.
- `PaginatedListPage<T>` with search, optional filters, pull-to-refresh, and infinite scroll.

### What was corrected / rejected

- **Bug fixed:** untyped `const []` in `AddPaginatedItemsByPageUseCaseParams` broke the view model at runtime (`List<dynamic>` vs `List<TEntity>`). Fix: `List<TEntity>.empty(growable: false)`.
- **Rejected:** factory constructor with a type parameter on `PaginatedListEntity.fromModel<TModel>` — not valid in Dart; replaced with static method `fromModel<T, TModel>`.
- **Adjusted:** initial load moved from `initState` + `ref` to first `build` via `Future.microtask` to avoid lifecycle issues in widget tests.

### Resulting files

- `lib/core/presentation/paginated_list_page.dart`
- `lib/core/presentation/providers/paginated_list_view_model.dart`
- `lib/features/episodes/`, `lib/features/locations/`

---

## 2. Rate limiting strategy (429) — architecture consultation

### Context

The app triggers multiple concurrent requests during infinite scroll, pull-to-refresh, and debounced search. The Rick & Morty API is public and can respond with **429 Too Many Requests**. Before implementing, I used AI as a sparring partner to compare approaches and pick the simplest option that fits the challenge scope.

### Prompt used

```markdown
I'm building a Flutter app with Dio against a public REST API (Rick & Morty).
Typical traffic: infinite scroll pagination, debounced name search (400ms), and pull-to-refresh.

Compare these client-side strategies for avoiding 429s and keeping UX predictable:
1. Request queue with automatic retry on 429
2. Semaphore / RateLimitGate with max in-flight requests
3. Serialize outbound calls with a fixed throttle (e.g. 1 request every 2s)
4. Debounce only — no client-side rate control

For each option, call out trade-offs: complexity, risk of stuck loaders, interaction with pagination state, and testability.

Recommend one approach for a 4–6 hour technical challenge and outline the ViewModel guards that should accompany it (pagination lock, partial failure UX, preserving nextPage on retry).
```

### Options evaluated

| Strategy | Pros | Cons | Verdict |
|----------|------|------|---------|
| **Queue + auto-retry on 429** | Transparent to callers | Retries on the same queue can block follow-up requests; hard to reason about in tests | Not chosen |
| **Semaphore / RateLimitGate** | Caps concurrency explicitly | Extra abstraction for a single API surface; more moving parts than needed | Not chosen |
| **Debounce only** | Minimal code | Does not protect scroll-triggered pagination bursts | Not chosen |
| **Serialized throttle (1 req / 2s)** | Simple, predictable, easy to debug | Slightly slower under heavy scroll | **Chosen** |

### Decision and implementation

**Chosen strategy:** serialize all outbound API calls in `ApiClient._throttle()` — one request every 2 seconds, no retry queue in the interceptor.

**Companion ViewModel rules** (also aligned with AI recommendation):

- `_paginationLocked` to prevent duplicate page fetches on fast scroll.
- Skip fetch when `maxScrollExtent <= 0` (list not scrollable yet).
- On partial failure (items already loaded): keep list visible, show `RetryWidget` at the bottom, preserve `nextPage` on 429 so the user retries the same page.

### Resulting files

- `packages/api_client/lib/src/api_client.dart`
- `lib/core/presentation/providers/paginated_list_view_model.dart`
- `lib/core/ui/retry_widget.dart`

---

## Explicit case: rejected generated code

**AI proposal:** add `Color indicatorColor` and UI helpers directly on `CharacterEntity` (domain layer).

**Decision:** **rejected**. Domain must not depend on Flutter. Status colors and card layout belong in `CharacterTile` (presentation). `species` and `status` stay as separate fields on the entity.

---

## Tests generated / reviewed with AI

- `test/core/domain/repository/repository_impl_test.dart`
- `test/features/characters/domain/use_cases/add_characters_by_page_use_case_test.dart`
- `test/features/characters/presentation/characters_page_test.dart`
- `test/core/presentation/providers/paginated_list_view_model_test.dart`

All verified green with `flutter test` before commit.

---

## Takeaways

1. **Watch Dart generics closely:** empty lists and parameterized factories are a common source of silent runtime bugs.
2. **Use AI for trade-off analysis** before committing to interceptors or retry queues — a short comparison table often beats iterating on the wrong pattern.
3. **Documenting rejections** matters as much as documenting wins — it shows technical judgment, not blind acceptance.
