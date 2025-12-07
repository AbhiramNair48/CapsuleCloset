import 'package:capsule_closet_app/screens/ai_chat_page.dart';
import 'package:capsule_closet_app/services/ai_service.dart';
import 'package:capsule_closet_app/services/data_service.dart';
import 'package:capsule_closet_app/models/clothing_item.dart';
import 'package:capsule_closet_app/models/friend.dart';
import 'package:capsule_closet_app/models/outfit.dart';
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
  void updateContext(List<ClothingItem> items) {}

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

  void addBotMessage(String text, {List<String>? imagePaths, List<String>? itemIds}) {
    _messages.add(Message(text: text, isUser: false, imagePaths: imagePaths, itemIds: itemIds));
    notifyListeners();
  }

  // Expose the extraction logic via a public method or test it via side effects
  // Since we are mocking AIService, we can't test the real logic here easily.
  // But the original request was to fix the "feature", which implies the integration.
  // We will create a separate unit test for AIService logic if needed.
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

class MockDataService extends ChangeNotifier implements DataService {
  @override
  List<ClothingItem> get clothingItems => [];
  @override
  List<Outfit> get outfits => [];
  @override
  List<Friend> get friends => [];
  @override
  List<ClothingItem> get filteredClothingItems => [];
  @override
  void addClothingItem(ClothingItem item) {}
  @override
  void removeClothingItem(String id) {}
  @override
  void updateClothingItem(ClothingItem updatedItem) {}
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
  List<ClothingItem> getClothingItemsByType(String type) => [];
  @override
  List<ClothingItem> getClothingItemsByColor(String color) => [];
  @override
  List<ClothingItem> getClothingItemsByMaterial(String material) => [];
}


void main() {
  // UI Tests
  testWidgets('AIChatPage displays outfit images', (WidgetTester tester) async {
    final mockAIService = MockAIService();
    final mockDataService = MockDataService();

    mockAIService.addBotMessage(
      'Here is an outfit',
      imagePaths: ['assets/images/clothes/shirt.png'],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AIService>.value(value: mockAIService),
          ChangeNotifierProvider<DataService>.value(value: mockDataService),
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
