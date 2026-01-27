import 'package:capsule_closet_app/models/clothing_item.dart';
import 'package:capsule_closet_app/services/data_service.dart';
import 'package:capsule_closet_app/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class MockStorageService extends StorageService {
  @override
  Future<void> deleteImage(String imageUrl) async {
    // Do nothing for mock
  }

  @override
  Future<void> updateImageMetadata(String imageUrl, bool isPublic) async {
    // Do nothing for mock
  }
}

void main() {
  late DataService dataService;
  late MockClient mockClient;
  late MockStorageService mockStorageService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockStorageService = MockStorageService();
    
    mockClient = MockClient((request) async {
      // Mock DELETE clothing item
      if (request.method == 'DELETE' && request.url.pathSegments.contains('closet')) {
        return http.Response('', 200);
      }
      return http.Response('', 404);
    });

    dataService = DataService(null, httpClient: mockClient, storageService: mockStorageService);
  });

  group('DataService', () {
    test('Initializes with mock data', () {
      expect(dataService.clothingItems, isEmpty); 
      expect(dataService.outfits, isEmpty);
      expect(dataService.friends, isEmpty);
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

    test('Removes clothing item', () async {
      final newItem = ClothingItem(
        id: 'test-id-remove',
        imagePath: 'path', // This might trigger StorageService delete, which might fail if real.
                           // But DataService catches that error.
        type: 'Type',
        material: 'Mat',
        color: 'Col',
        style: 'Style',
        description: 'Desc',
      );
      dataService.addClothingItem(newItem);
      
      await dataService.removeClothingItem('test-id-remove');
      
      expect(dataService.clothingItems.contains(newItem), isFalse);
    });

    test('Filters clothing items', () {
      final shirt = ClothingItem(
        id: '1', imagePath: '', type: 'Shirt', material: '', color: '', style: '', description: ''
      );
      dataService.addClothingItem(shirt);

      dataService.filterClothingItemsByType('Shirt');
      
      for (var item in dataService.filteredClothingItems) {
        expect(item.type.toLowerCase(), contains('shirt'));
      }
    });

    test('Reset filter returns all items', () {
      final shirt = ClothingItem(
        id: '1', imagePath: '', type: 'Shirt', material: '', color: '', style: '', description: ''
      );
      dataService.addClothingItem(shirt);

      dataService.filterClothingItemsByType('Shirt');
      final filteredLength = dataService.filteredClothingItems.length;
      
      dataService.filterClothingItemsByType(null);
      
      expect(dataService.filteredClothingItems.length, dataService.clothingItems.length);
      expect(dataService.filteredClothingItems.length, greaterThanOrEqualTo(filteredLength));
    });
  });
}
