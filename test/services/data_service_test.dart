import 'package:capsule_closet_app/models/clothing_item.dart';
import 'package:capsule_closet_app/services/data_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DataService dataService;

  setUp(() {
    dataService = DataService();
  });

  group('DataService', () {
    test('Initializes with mock data', () {
      expect(dataService.clothingItems, isNotEmpty);
      expect(dataService.outfits, isNotEmpty);
      expect(dataService.friends, isNotEmpty);
    });

    test('Adds clothing item', () {
      final initialLength = dataService.clothingItems.length;
      final newItem = ClothingItem(
        id: 'test-id',
        imagePath: 'assets/images/clothes/shirt.png',
        type: 'Shirt',
        material: 'Cotton',
        color: 'Blue',
        style: 'Casual',
        description: 'A nice shirt',
      );

      dataService.addClothingItem(newItem);

      expect(dataService.clothingItems.length, initialLength + 1);
      expect(dataService.clothingItems.contains(newItem), isTrue);
    });

    test('Removes clothing item', () {
      final itemToRemove = dataService.clothingItems.first;
      final initialLength = dataService.clothingItems.length;

      dataService.removeClothingItem(itemToRemove.id);

      expect(dataService.clothingItems.length, initialLength - 1);
      expect(dataService.clothingItems.contains(itemToRemove), isFalse);
    });

    test('Filters clothing items', () {
      // Assumption: Mock data contains at least one 'Shirt'
      dataService.filterClothingItemsByType('Shirt');
      
      for (var item in dataService.filteredClothingItems) {
        expect(item.type.toLowerCase(), contains('shirt'));
      }
    });

    test('Reset filter returns all items', () {
      dataService.filterClothingItemsByType('Shirt');
      final filteredLength = dataService.filteredClothingItems.length;
      
      dataService.filterClothingItemsByType(null);
      
      expect(dataService.filteredClothingItems.length, dataService.clothingItems.length);
      expect(dataService.filteredClothingItems.length, greaterThan(filteredLength));
    });
  });
}
