# Capsule Closet App - Development Guide

## Project Overview

Capsule Closet is a Flutter application that helps users manage their wardrobe and receive AI-powered fashion recommendations. The app allows users to upload pictures of their clothes, organize them into categories, and interact with an AI stylist that suggests outfit combinations based on the user's inventory, preferences, and weather conditions.

### Key Features
- User authentication (login/signup)
- Wardrobe management (add, categorize, and organize clothing items)
- AI-powered fashion recommendations using Google's Gemini
- Outfit creation and management
- Friend connections
- Dark/light theme support

### Technology Stack
- **Frontend**: Flutter/Dart
- **State Management**: Provider
- **AI Integration**: Google Generative AI SDK
- **Backend**: Custom Dart backend (using Shelf framework)
- **Database**: MySQL
- **External APIs**: Google Gemini (both LLM and Vision)

## Project Structure

```
CapsuleCloset/
├── lib/
│   ├── config/           # Configuration constants
│   ├── models/           # Data models (ClothingItem, Outfit, etc.)
│   ├── screens/          # UI screens
│   ├── services/         # Business logic services
│   └── theme/            # Theme definitions
├── assets/
│   └── images/           # Static assets
├── backend/             # Backend server implementation
├── test/                # Unit/integration tests
└── .env                 # Environment variables
```

## Building and Running

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Android Emulator or physical device
- Google Gemini API Keys (for AI features)

### Setup Instructions
1. Clone the repository to your local computer
2. Install dependencies: `flutter pub get`
3. Set up environment variables in `.env` file with your Gemini API keys:
   ```
   GEMINI_LLM_API_KEY=your_api_key_here
   GEMINI_VISION_API_KEY=your_vision_api_key_here
   ```
4. Run the app: `flutter run`

### Backend Server
The app connects to a backend server running on `http://127.0.0.1:8080` (or `http://10.0.2.2:8080` for Android emulators).
- The backend is implemented in Dart using the Shelf framework
- Database connection uses MySQL via the mysql1 package
- Backend code is located in the `/backend` directory

## Architecture & Services

### Core Services
1. **AuthService**: Manages user authentication (login, signup, logout)
2. **DataService**: Handles data management (clothing items, outfits, friends)
3. **AIService**: Connects to Google Gemini for AI-powered styling suggestions
4. **ThemeService**: Manages light/dark theme preferences

### Data Flow
- Authentication is required for app access with predefined test credentials
- All data is currently stored locally using mock data implementations
- AI service sends user context and receives outfit recommendations
- Outfit recommendations include references to specific clothing items in the user's closet

### Models
- **ClothingItem**: Represents individual clothing pieces with properties like type, material, color, style
- **Outfit**: Collection of clothing items with styling information
- **UserProfile**: User preferences and style information
- **Friend**: Social connections within the app

## Development Conventions

### State Management
- Uses Provider pattern for state management
- Services extend ChangeNotifier to support reactive updates
- MultiProvider handles dependency injection in main.dart

### UI Components
- Follows Flutter Material Design guidelines
- Responsive layout with adaptive sizing
- Theme support includes both light and dark modes

### Testing
- Unit tests should be added in the `/test` directory
- The app follows Flutter's testing best practices
- Uses Flutter's standard linting rules

### Coding Style
- Uses Flutter's standard linting configuration
- Follows Dart's official style guide
- Proper documentation with doc comments
- Error handling with try-catch blocks where appropriate

## Important Notes

- The backend server needs to be running for full app functionality
- API keys for Google Gemini are required for AI features
- The current implementation uses mock data for demonstration purposes
- The Android emulator needs to connect to localhost via 10.0.2.2