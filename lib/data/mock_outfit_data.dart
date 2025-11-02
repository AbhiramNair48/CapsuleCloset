import '../models/outfit.dart';
import 'mock_clothing_data.dart';

/// Mock data for saved outfits
class MockOutfitData {
  static List<Outfit> getOutfits() {
    final items = MockClothingData.items;
    
    return [
      Outfit(
        id: 'outfit1',
        name: 'Casual Summer',
        items: [
          items[0], // Dress
          items[2], // Jeans
        ],
        savedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Outfit(
        id: 'outfit2',
        name: 'Business Professional',
        items: [
          items[1], // Shirt
          items[3], // Blazer
          items[7], // Trousers
        ],
        savedDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Outfit(
        id: 'outfit3',
        name: 'Evening Elegant',
        items: [
          items[4], // Skirt
          items[1], // Shirt
          items[3], // Blazer
        ],
        savedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Outfit(
        id: 'outfit4',
        name: 'Cozy Winter',
        items: [
          items[5], // Sweater
          items[7], // Trousers
          items[6], // Jacket
        ],
        savedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Outfit(
        id: 'outfit5',
        name: 'Casual Weekend',
        items: [
          items[2], // Jeans
          items[1], // Shirt
          items[6], // Jacket
        ],
        savedDate: DateTime.now(),
      ),
    ];
  }
}

