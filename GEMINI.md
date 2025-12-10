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
*   **Backend (`backend/`):** Standalone Dart server (Shelf + MySQL) for data persistence (currently separate).

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