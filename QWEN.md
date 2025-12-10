# Capsule Closet Application - QWEN Context

## Project Overview
Capsule Closet is a Flutter mobile application that allows users to create and manage a digital wardrobe. The app provides a virtual closet where users can store, organize, and coordinate their clothing items and outfits. This is a personal project built with Flutter for cross-platform mobile development (Android, iOS).

## Architecture & Technologies
- **Framework**: Flutter (Dart) with Material Design 3
- **Platform**: Android, iOS (cross-platform)
- **State Management**: Provider pattern using ChangeNotifierProvider
- **Authentication**: Mock authentication service for development/testing
- **UI Components**: Custom widgets for displaying clothing items and managing the closet interface
- **Dependencies**: 
  - google_fonts: ^6.3.2
  - provider: ^6.1.2 (for state management)
  - cupertino_icons: ^1.0.8
  - flutter_lints: ^5.0.0 (for code quality)

## Key Features
- User authentication (login with mock service)
- AI Chatbot interface for outfit recommendations
- Digital closet with clothing items displayed in a grid
- Clothing item details view
- Tab-based navigation (Home/Chat, Closet, Add, Friends, Settings)
- Two-tab view within Closet (Clothes, Outfits)
- Friend management system
- Outfit creation and saving functionality

## Project Structure
```
lib/
├── main.dart           # App entry point, MaterialApp setup with MultiProvider
├── data/
│   ├── mock_clothing_data.dart  # Sample clothing items
│   ├── mock_outfit_data.dart    # Sample outfits
│   └── mock_friends_data.dart   # Sample friends and their closets
├── models/
│   ├── clothing_item.dart  # Data model for clothing items
│   ├── friend.dart         # Data model for friends
│   └── outfit.dart         # Data model for outfits
├── services/
│   ├── auth_service.dart   # Mock authentication service
│   └── data_service.dart   # Data management service
├── widgets/
│   ├── apparel_info_overlay.dart # Clothing details overlay
│   ├── closet_content.dart       # Grid view of clothing items
│   ├── clothing_item_card.dart   # Individual clothing item display
│   ├── outfit_card.dart          # Outfit display card
│   └── outfit_detail_drawer.dart # Outfit details view
└── screens/
    ├── ai_chat_page.dart        # AI chat interface for outfit recommendations
    ├── closet_screen.dart       # Main closet screen with tab view
    ├── friend_closet_page.dart  # Friend's closet screen
    ├── friends_page.dart        # Friends list screen
    ├── login_screen.dart        # Login authentication screen
    ├── main_navigation_screen.dart # Main navigation and bottom tabs
    └── saved_outfits_screen.dart   # Outfits tab content
```

## Authentication
The app uses a mock authentication service (`AuthService`) for development purposes. It includes:
- Predefined user credentials (test@example.com/password123 and user@example.com/testpass123)
- Login functionality with simulated network delay
- Password reset functionality

## Data Model
The `ClothingItem` model contains:
- id (String): Unique identifier
- imagePath (String): Asset path for the clothing image
- type (String): Category of clothing (e.g., Dress, Shirt, Jeans)
- material (String): Fabric type (e.g., Cotton, Denim, Wool)
- color (String): Color of the item
- style (String): Style type (e.g., Casual, Formal, Classic)
- description (String): Brief description of the item

## UI Components
- `MainNavigationScreen`: Main screen with bottom navigation and tabbed content
- `ClosetContent`: Grid view showing clothing items
- `ClothingItemCard`: Individual card for each clothing item
- `ApparelInfoOverlay`: Modal displaying detailed information about a selected clothing item
- `AIChatPage`: Chat interface for interacting with AI for outfit recommendations

## Assets
- Images stored in `assets/images/` and `assets/images/clothes/`
- Contains app logo and sample clothing images (dress.png, shirt.png, jeans.png, blazer.png, skirt.png, sweater.png, jacket.png, trousers.png)

## Building and Running
1. Ensure Flutter SDK is installed and configured
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` in the project directory to launch the app

## Development Notes
- The app currently uses mock data and authentication for development
- Several features are marked as "under development" (Add New Item, Friends page, Settings)
- The application uses Material Design 3 with a pink color scheme (ColorScheme.fromSeed(seedColor: Colors.pink))
- Bottom navigation includes Home/Chat, Closet, Add, Friends, and Settings tabs
- Closet tab has sub-tabs for "Clothes" and "Outfits"
- State management is implemented using Provider pattern with ChangeNotifier
- Responsive design with grid views for clothing items and outfits

## Future Enhancements
- Implement real authentication backend
- Add functionality for adding new clothing items
- Implement friends feature with social functionality
- Add CRUD operations for managing clothing items
- Advanced outfit creation and saving functionality
- Backend integration for data persistence
- Enhanced AI chatbot with real recommendations

## Testing Credentials
For testing the login functionality:
- Email: test@example.com, Password: password123
- Email: user@example.com, Password: testpass123

## Qwen Added Memories
- Flutter Material 3 Best Practices: 1) Use ColorScheme.fromSeed() with a seed color for harmonious themes, 2) Enable useMaterial3: true (default since Flutter 3.16), 3) Use Material 3 typography scales, 4) Apply consistent elevation values, 5) Ensure accessibility with proper contrast and touch targets, 6) Use new Material 3 components like NavigationBar, FilledButton, etc., 7) Implement adaptive layouts for different screen sizes
- Flutter Provider Pattern Best Practices: 1) Use ChangeNotifierProvider for ChangeNotifier objects, 2) Use context.watch() to listen for changes, context.read() to get value without listening, 3) Use MultiProvider to avoid nesting, 4) Use context.select() for performance optimization to listen only to specific properties, 5) Always dispose resources properly, 6) Use ProxyProvider to combine values from multiple providers, 7) Don't modify state from descendants during build, 8) Use Future.microtask for async initialization in initState