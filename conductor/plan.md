# Capsule Closet Refactor Plan

## Pre-refactor Static Analysis Table

| Metric/Issue                | Current State                        | Notes                                                                 |
| --------------------------- | ------------------------------------ | --------------------------------------------------------------------- |
| Total Tests                 | 22 (Frontend) + 1 (Backend)          | All passing.                                                          |
| Static Analysis (Linter)    | 0 issues                             | Both `flutter analyze` and `dart analyze` pass.                       |
| Duplication Hotspots        | `GlassContainer` & `TextFormField`   | `login_screen.dart` and `profile_screen.dart` define similar widgets. |
| Inconsistency               | `SignUpScreen` styling               | Not using `GlassScaffold` like Login/Profile screens.                 |
| Backend API Boilerplate     | `api_handlers.dart`                  | Repeated `jsonDecode`, `try/catch`, and response wrappers.            |
| Data Service API Calls      | `data_service.dart`                  | Repeated `http` calls with identical error-catching boilerplate.      |

## Prioritized Task List

### Task 1: Extract `GlassTextField`
- **Goal:** Unify `TextFormField` within `GlassContainer` instances.
- **Files touched:** `lib/widgets/glass_text_field.dart`, `lib/screens/login_screen.dart`, `lib/screens/profile_screen.dart`
- **Risk Level:** Low
- **Rollback Plan:** `git checkout HEAD -- lib/`

### Task 2: Standardize `SignUpScreen` to Glass Theme
- **Goal:** Update `sign_up_screen.dart` to use `GlassScaffold` and `GlassTextField` for aesthetic consistency.
- **Files touched:** `lib/screens/sign_up_screen.dart`
- **Risk Level:** Medium (UI refactor)
- **Rollback Plan:** `git checkout HEAD -- lib/screens/sign_up_screen.dart`

### Task 3: Reduce API Call Boilerplate in `DataService`
- **Goal:** Create private helper `_apiCall` to handle common HTTP `GET`/`POST` operations, JSON parsing, and error catching.
- **Files touched:** `lib/services/data_service.dart`
- **Risk Level:** High (touches all data operations)
- **Rollback Plan:** `git checkout HEAD -- lib/services/data_service.dart`

### Task 4: Standardize Backend API Handlers
- **Goal:** Add higher-order function `_withJsonData` or `_handleRequest` in `api_handlers.dart` to manage repetitive read, decode, and error catching.
- **Files touched:** `backend/lib/api_handlers.dart`
- **Risk Level:** High (touches backend entry points)
- **Rollback Plan:** `git checkout HEAD -- backend/lib/api_handlers.dart`
