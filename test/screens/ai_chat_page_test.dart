import 'package:capsule_closet_app/screens/ai_chat_page.dart';
import 'dart:async';
import 'package:capsule_closet_app/services/ai_service.dart';
import 'package:capsule_closet_app/services/data_service.dart';
import 'package:capsule_closet_app/services/weather_service.dart';
import 'package:capsule_closet_app/models/clothing_item.dart';
import 'package:capsule_closet_app/models/friend.dart';
import 'package:capsule_closet_app/models/outfit.dart';
import 'package:capsule_closet_app/models/user_profile.dart';
import 'package:capsule_closet_app/models/pending_friend_request.dart';
import 'package:capsule_closet_app/widgets/outfit_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Mock AIService
class MockAIService extends ChangeNotifier implements AIService {
  final List<Message> _messages = [];
  
  @override
  List<Message> get messages => _messages;

  @override
  bool get isLoading => false;

  @override
  void updateContext(List<ClothingItem> items, UserProfile userProfile, {String? weatherInfo}) {}

  @override
  void startChat() {}

  @override
  Future<void> sendMessage(String text) async {
    _messages.add(Message(text: text, isUser: true));
    notifyListeners();
  }

  @override
  ({String cleanText, List<String> imagePaths, List<String> itemIds}) processResponse(String text) {
    return (cleanText: text, imagePaths: <String>[], itemIds: <String>[]);
  }

  @override
  void markMessageAsAnimated(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages[index].hasAnimated = true;
    }
  }

  @override
  void resetChat() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void injectBotResponse(String text) {
     addBotMessage(text);
  }

  void addBotMessage(String text, {List<String>? imagePaths, List<String>? itemIds}) {
    _messages.add(Message(text: text, isUser: false, imagePaths: imagePaths, itemIds: itemIds));
    notifyListeners();
  }
}

// Helper to find text in RichText widgets
Finder findRichTextContaining(String text) {
  return find.byWidgetPredicate((widget) {
    if (widget is RichText) {
      final span = widget.text;
      if (span is TextSpan) {
        final plainText = span.toPlainText();
        return plainText.contains(text);
      }
    }
    return false;
  });
}

class ManualMockWeatherService implements WeatherService {
  @override
  Future<Map<String, dynamic>> getCurrentWeather() async {
    return {
      'current_temp': 72.0,
      'current_weather_code': 0,
      'max_temp': 80.0,
      'min_temp': 60.0,
      'precip_chance': 0,
      'daily_weather_code': 0,
      'unit': '°F',
    };
  }
}

class MockDataService extends ChangeNotifier implements DataService {
  @override
  Stream<void> get itemChangeStream => const Stream.empty();

  @override
  List<ClothingItem> get clothingItems => [];
  @override
  List<Outfit> get outfits => [];
  @override
  List<Friend> get friends => [];
  @override
  List<ClothingItem> get filteredClothingItems => [];
  @override
  List<PendingFriendRequest> get pendingFriendRequests => [];
  @override
  UserProfile get userProfile => const UserProfile();

  @override
  void updateAuth(dynamic auth) {}

  @override
  void addClothingItem(ClothingItem item) {}
  
  @override
  Future<void> removeClothingItem(String id) async {}
  
  @override
  Future<void> updateClothingItem(ClothingItem updatedItem) async {}
  
  @override
  void filterClothingItemsByType(String? type) {}
  
  @override
  void addOutfit(Outfit outfit) {}
  
  @override
  void updateOutfit(Outfit updatedOutfit) {}
  
  @override
  void removeOutfit(String id) {}
  
  @override
  void removeFriend(String id) {}
  
  @override
  Future<void> updateUserProfile(UserProfile profile) async {}

  @override
  List<ClothingItem> getClothingItemsByType(String type) => [];
  
  @override
  List<ClothingItem> getClothingItemsByColor(String color) => [];
  
  @override
  List<ClothingItem> getClothingItemsByMaterial(String material) => [];

  @override
  List<ClothingItem> get hamperItems => [];

  @override
  Future<void> markItemClean(String itemId) async {}

  @override
  Future<void> markItemDirty(String itemId) async {}

  @override
  Future<void> markAllClean() async {}

  @override
  Future<void> fetchClothingItems(String userId) async {}

  @override
  Future<void> fetchFriends(String userId) async {}

  @override
  Future<void> fetchOutfits(String userId) async {}

  @override
  Future<void> fetchPendingFriendRequests(String userId) async {}

  @override
  Future<bool> respondToFriendRequest(String friendshipId, String status) async => true;

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async => [];

  @override
  Future<bool> sendFriendRequest(String senderUserEmail, String recipientId) async => true;

  @override
  Future<void> updateClothingItemPublicStatus(String itemId, bool isPublic) async {}

  @override
  Future<ClothingItem?> uploadClothingItem({required XFile imageFile, required ClothingItem recognizedData, required String userId}) async => null;
  
  @override
  Future<void> loadNotificationSettings(String userId) async {}

  @override
  Future<void> saveNotificationSettings(bool isEnabled, String? time, String? occasion) async {}
}


void main() {
  // UI Tests
  testWidgets('AIChatPage displays outfit images', (WidgetTester tester) async {
    final mockAIService = MockAIService();
    final mockDataService = MockDataService();
    final mockWeatherService = ManualMockWeatherService();

    mockAIService.addBotMessage(
      'Here is an outfit',
      imagePaths: ['assets/images/clothes/shirt.png'],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AIService>.value(value: mockAIService),
          ChangeNotifierProvider<DataService>.value(value: mockDataService),
          Provider<WeatherService>.value(value: mockWeatherService),
        ],
        child: const MaterialApp(
          home: AIChatPage(),
        ),
      ),
    );
    
    await tester.pumpAndSettle();

    expect(find.byType(OutfitPreview), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}