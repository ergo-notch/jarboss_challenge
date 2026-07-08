# USO_IA.md — AI Usage in Jarboss Challenge

This document describes how AI (Cursor / Claude) was used during development, what was delegated, structured prompts that worked well, and cases where generated code was **reviewed, corrected, or rejected**.

---

## AI Usage Strategies

| Strategy                                 | Description                                                                                              | When to use                                      |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| **Scaffold + wire end-to-end**           | Ask for a reusable widget + full stack integration (UI → ViewModel → UseCase → Repository → DataSource). | New features (search, filters, states)           |
| **Observability via structured logging** | Ask for a dedicated API logger with readable console output, enabled only in debug.                      | Intermittent API failures (429, empty responses) |
| **Architecture review before accepting** | Ask whether a pattern fits the use case (debounce vs throttle vs lock).                                  | Performance / rate-limit issues                  |

---

## 1. API Logger — Readable Console Output

### Context

GraphQL calls were failing intermittently (`Too Many Requests`, empty results). Raw `graphql_flutter` errors were hard to scan in the debug console during infinite scroll and search.

### What was delegated to AI

- Design a small `ApiLogger` class in `packages/graphql_client`
- Wrap `GraphQLServiceImpl.query` / `mutation` with request → success / failure logging
- Use `dart:developer.log` with a fixed tag (`API`) for DevTools filtering
- Enable only in debug via `kDebugMode` in `client_provider.dart`

### What was kept / adjusted after review

- **Kept:** `→` / `✓` / `✗` prefixes, duration in ms, variables on request, top-level response keys on success
- **Kept:** Logger injected as optional dependency (testable, no Flutter import inside the package)
- **Not added:** Full response body logging (too noisy; keys are enough for pagination debugging)

### Resulting files

- `packages/graphql_client/lib/src/api_logger.dart`
- `packages/graphql_client/lib/src/connection/graphql_service.dart`
- `lib/core/providers/client_provider.dart`

### Sample console output

```
[API] → QUERY
        query: query GetCharacters($page: Int!, $filter: FilterCharacter) { ... }
        variables: {page: 2, filter: null}

[API] ✓ QUERY (312ms)
        keys: [characters]

[API] ✗ QUERY (98ms)
        error: GraphQLErrorException: Too Many Requests
```

---

### Structured prompt — API Logger

Use this prompt when you need a similar logger in another Flutter/Dart project:

```markdown
## Role

You are a senior Dart developer working on a Flutter app with a custom GraphQL client package.

## Goal

Add debug-only API logging so every GraphQL request is visible in the console with a human-readable format. I need to diagnose intermittent failures (429, network errors, empty data) during infinite scroll and search.

## Constraints

- Logging must live in the `graphql_client` package (no `flutter` dependency in that package).
- Use `dart:developer.log` with a consistent `name` tag (e.g. `'API'`).
- Enable logging only in debug mode from the app layer (`kDebugMode`).
- Do NOT log full response payloads — only top-level keys and metadata.
- Inject the logger into `GraphQLServiceImpl` (constructor injection, optional with default).
- Wrap both `query` and `mutation` in a single private `_execute` method.
- Measure elapsed time with `Stopwatch`.

## Log format

1. **Request:** `→ QUERY` or `→ MUTATION` + single-line query summary + variables map
2. **Success:** `✓ QUERY (123ms)` + `keys: [characters, ...]`
3. **Failure:** `✗ QUERY (45ms)` + error message + stack trace via `developer.log`
```
