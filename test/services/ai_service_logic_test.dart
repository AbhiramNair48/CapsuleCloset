import 'package:capsule_closet_app/services/ai_service.dart';
import 'package:capsule_closet_app/models/clothing_item.dart';
import 'package:capsule_closet_app/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIService Extraction Logic', () {
    late AIService aiService;

    setUp(() {
      // Provide a dummy key to bypass AppConstants/dotenv access
      aiService = AIService(apiKey: 'test_key');
    });

    test('extracts IDs and cleans text', () {
      final items = [
        const ClothingItem(
          id: '123',
          imagePath: 'path/to/image1.png',
          type: 'Top',
          material: 'Cotton',
          color: 'White',
          style: 'Casual',
          description: 'White shirt',
        ),
        const ClothingItem(
          id: '456',
          imagePath: 'path/to/image2.png',
          type: 'Bottom',
          material: 'Denim',
          color: 'Blue',
          style: 'Casual',
          description: 'Blue jeans',
        ),
      ];

      aiService.updateContext(items, const UserProfile());

      const rawResponse = 'You should wear the White shirt <<ID:123>> and Blue jeans <<ID:456>>.';
      final result = aiService.processResponse(rawResponse);

      expect(result.cleanText, 'You should wear the White shirt  and Blue jeans .');
      expect(result.imagePaths, containsAll(['path/to/image1.png', 'path/to/image2.png']));
    });

    test('handles unknown IDs gracefully', () {
       aiService.updateContext([], const UserProfile());
       const rawResponse = 'Wear this <<ID:unknown>>.';
       final result = aiService.processResponse(rawResponse);
       
       expect(result.cleanText, 'Wear this .');
       expect(result.imagePaths, isEmpty);
    });
    
    test('deduplicates images', () {
      final items = [
        const ClothingItem(
          id: '123',
          imagePath: 'path/to/image1.png',
          type: 'Top',
          material: 'Cotton',
          color: 'White',
          style: 'Casual',
          description: 'White shirt',
        ),
      ];
      aiService.updateContext(items, const UserProfile());
      
      const rawResponse = 'Wear shirt <<ID:123>>. Really, wear the shirt <<ID:123>>.';
      final result = aiService.processResponse(rawResponse);
      
      expect(result.imagePaths.length, 1);
    });

    test('ignores IDs outside "What to wear" section', () {
      final items = [
        const ClothingItem(
          id: '123',
          imagePath: 'path/to/shirt.png',
          type: 'Top',
          material: 'Cotton',
          color: 'White',
          style: 'Casual',
          description: 'White shirt',
        ),
        const ClothingItem(
          id: '456',
          imagePath: 'path/to/shoes.png',
          type: 'Shoes',
          material: 'Leather',
          color: 'Brown',
          style: 'Formal',
          description: 'Brown shoes',
        ),
      ];
      aiService.updateContext(items, const UserProfile());
      
      const rawResponse = '''
**What to wear:** White shirt <<ID:123>>.

**Why this works:** Unlike the Brown shoes <<ID:456>> from before...
''';
      final result = aiService.processResponse(rawResponse);
      
      expect(result.imagePaths, contains('path/to/shirt.png'));
      expect(result.imagePaths, isNot(contains('path/to/shoes.png')));
      // Text should still be cleaned of all IDs
      expect(result.cleanText, isNot(contains('<<ID:'))); 
    });
  });
}
