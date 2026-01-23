# Capsule Closet

## Project Overview
Capsule Closet is a Flutter-based mobile application designed to help users manage their wardrobe, create outfits, and connect with friends. It features a virtual closet, AI-powered chat assistance, and social features for sharing style.

### Key Technologies
*   **Framework:** Flutter (Dart)
*   **State Management:** Provider (`ChangeNotifier`)
*   **UI Components:** Material Design 3, Google Fonts
*   **Dependencies:** `image_picker`, `google_fonts`, `provider`, `cupertino_icons`

### Architecture
The application follows a layered architecture:
*   **Screens (`lib/screens`):** UI components for different application pages.
*   **Services (`lib/services`):** Business logic and data management (`AuthService`, `DataService`).
*   **Models (`lib/models`):** Data structures representing domain objects (`ClothingItem`, `Outfit`, `Friend`).
*   **Data (`lib/data`):** Mock data sources.
*   **Widgets (`lib/widgets`):** Reusable UI elements.
*   **Theme (`lib/theme`):** Application theme configuration.
*   **Backend (`backend/`):** Standalone Dart server (Shelf + MySQL) for data persistence.

## Building and Running

### Prerequisites
*   Flutter SDK
*   Android Emulator or iOS Simulator

### Commands
*   **Run the app:**
    ```bash
    flutter run
    ```
*   **Run tests:**
    ```bash
    flutter test
    ```
*   **Analyze code:**
    ```bash
    flutter analyze
    ```

## Development Conventions

### Coding Style
*   Adheres to `flutter_lints` rules.
*   Uses `const` constructors where possible.
*   Follows standard Dart naming conventions (camelCase for variables/functions, PascalCase for classes).

### State Management
*   Uses the `Provider` package.
*   Services (e.g., `DataService`, `AuthService`) extend `ChangeNotifier` to propagate state changes.
*   `MultiProvider` is configured in `lib/main.dart` to inject services at the root level.

### Theme
*   **Primary Color:** Pink
*   **Design System:** Material 3
*   **Typography:** Google Fonts (Dancing Script for headers)
*   **Configuration:** Defined in `lib/theme/app_theme.dart`.

## Directory Structure
*   `lib/`: Main source code.
    *   `screens/`: UI pages.
    *   `widgets/`: Reusable components.
    *   `services/`: State and logic.
    *   `models/`: Data classes.
    *   `data/`: Mock data.
    *   `theme/`: Theme definitions.
*   `backend/`: Server-side code (Dart/Shelf).
    *   `bin/`: Server entry point (`server.dart`).
*   `assets/`: Static assets (images, icons).
*   `test/`: Unit and widget tests.
    *   `screens/`: Widget tests for screens.
    *   `widgets/`: Widget tests for reusable components.
    *   `services/`: Unit tests for services.
*   `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`: Platform-specific configuration files.

## Refactor Log (November 24, 2025)
*   **Linting:** Removed unused code (`_showUnderDevelopmentDialog`) in `main_navigation_screen.dart`.
*   **Architecture:** Centralized theme configuration into `lib/theme/app_theme.dart`.
*   **Refactoring:** Updated `LoginScreen` to use dynamic theme colors instead of hardcoded values.
*   **Testing:**
    *   Added widget tests for `LoginScreen` (`test/screens/login_screen_test.dart`).
    *   Added unit tests for `DataService` (`test/services/data_service_test.dart`).
    *   Verified 12 passing tests in total.

## Refactor Log (December 5, 2025)
*   **Build & Test Fixes:**
    *   Fixed `MockAIService` in `test/screens/ai_chat_page_test.dart` to implement missing `processResponse` method.
    *   Resolved compilation errors preventing test execution.
    *   Verified **17 passing tests** (up from failing state).
*   **Architecture & Theme:**
    *   Updated `AppTheme` (`lib/theme/app_theme.dart`) to include `DialogThemeData` and a robust `InputDecorationTheme`.
    *   Enforced theme usage in `LoginScreen`, removing hardcoded `Colors.pink` borders and `Colors.red`/`Colors.orange` hardcodes in favor of `Theme.of(context).colorScheme`.
*   **Refactoring & Deduplication:**
    *   Created `DeleteIconButton` (`lib/widgets/delete_icon_button.dart`) to deduplicate delete button logic in `UploadToClosetPage`.
    *   Updated `UploadToClosetPage`, `MainNavigationScreen`, and `OutfitDetailDrawer` to replace hardcoded colors with semantic theme colors (`error`, `primary`, `onSurfaceVariant`).
*   **Code Quality:**
    *   Addressed linter warnings (unused variables/fields).
    *   Achieved 0 issues in `flutter analyze`.

## Refactor Log (December 9, 2025)
*   **Backend cleanup:**
    *   Converted `backend/` from a misconfigured Flutter project to a pure Dart server project (removed unused Flutter dependencies and assets).
    *   Fixed lint errors in `backend/lib/database/server.dart`.
*   **Refactoring:**
    *   Created `GenericDeleteScreen<T>` (`lib/widgets/generic_delete_screen.dart`) to consolidate item deletion logic.
    *   Refactored `DeleteClothingItemsScreen`, `DeleteFriendsScreen`, and `DeleteOutfitsScreen` to use the new generic widget, removing ~150 lines of duplicated code.
    *   Extracted `FriendCard` to `lib/widgets/friend_card.dart` for reuse.
*   **Testing:**
    *   Created `test/widgets/generic_delete_screen_test.dart` with robust interaction tests.
    *   Verified **19 passing tests** total.

## Refactor Log (December 22, 2025)
*   **Test Fixes:**
    *   Resolved multiple compilation errors in `test/` by updating `MockDataService`, `MockAuthService` and `MockAIService` to match current Service signatures.
    *   Fixed `DataService` constructor usage in tests.
    *   Refactored `AIChatPage` and `WeatherService` to use Dependency Injection (Provider) to fix `pumpAndSettle` timeout in tests.
    *   Verified **21 passing tests** (1 skipped).
*   **Backend Refactor:**
    *   Moved server entry point from `backend/lib/database/server.dart` to `backend/bin/server.dart` to follow Dart conventions.
    *   Fixed type mismatch bugs (`String` vs `int` IDs) in `server.dart` affecting friend requests and lookups.
*   **Code Quality:**
    *   Addressed `avoid_print` lints in backend.

## Refactor Log (January 11, 2026)
*   **Code Quality & Linting:**
    *   Resolved all remaining `flutter analyze` issues (unused imports, deprecated members, unused fields).
    *   Cleaned up `AuthService` by removing unused fields and methods.
    *   Achieved **0 issues** in both `flutter analyze` and `dart analyze backend`.
*   **Backend Architecture:**
    *   Refactored `backend/bin/server.dart` to use `ApiHandlers` class, eliminating massive code duplication and improving separation of concerns.
    *   Added `test` dependency to backend and established a baseline test infrastructure in `backend/test/`.
*   **Robustness & Bug Fixes:**
    *   Updated `AIChatPage` and `ClothingItemCard` to support both asset and network images dynamically.
    *   Fixed a critical `pumpAndSettle` timeout in `AIChatPage` tests caused by `CachedNetworkImage` behavior with invalid paths.
*   **Testing:**
    *   Verified **22 passing tests** total (all frontend tests green, including previously failing AI chat tests).
    *   Added backend sanity test.

## Refactor Log (January 23, 2026)
*   **Deprecation Fixes:** Removed deprecated `isInDebugMode` in `BackgroundService`.
*   **Dependency Updates:** Upgraded all packages to latest minor/patch versions.
*   **Refactoring - App:**
    *   Extracted `ChatBubble`, `OutfitPreview`, and `WeatherModule` from `AIChatPage` to `lib/widgets`.
    *   Extracted `ImageSelectionDrawerContent` from `UploadToClosetPage` to `lib/widgets`.
    *   Cleaned up `UploadToClosetPage` logic.
    *   Fixed hardcoded URL in `AppConstants` (added `http://`).
*   **Refactoring - Backend:**
    *   Refactored `backend/bin/server.dart` to use `shelf_router` for cleaner routing.
    *   Refactored `backend/lib/api_handlers.dart` to use `shelf.Request` and `shelf.Response`.
    *   Added explicit dependency on `http_parser`.
*   **Testing:**
    *   Refactored `DataService` to use Dependency Injection for `http.Client`.
    *   Fixed and unskipped `DataService Removes clothing item` test using `MockClient`.
    *   Verified all tests pass (22 passing in App, 1 passing in Backend).