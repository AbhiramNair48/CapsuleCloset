import '../models/outfit.dart';
import '../models/clothing_item.dart';
import 'mock_clothing_data.dart';

/// Mock data for saved outfits
class MockOutfitData {
  // Predefined constants for outfit names
  static const String outfitCasualSummer = 'Casual Summer';
  static const String outfitBusinessProfessional = 'Business Professional';
  static const String outfitEveningElegant = 'Evening Elegant';
  static const String outfitCozyWinter = 'Cozy Winter';
  static const String outfitCasualWeekend = 'Casual Weekend';

  static List<Outfit> getOutfits() {
    final items = MockClothingData.items;

    // Use constants to identify items more reliably
    final dress = items.firstWhere((item) => item.type == MockClothingData.typeDress);
    final shirt = items.firstWhere((item) => item.type == MockClothingData.typeShirt);
    final jeans = items.firstWhere((item) => item.type == MockClothingData.typeJeans);
    final blazer = items.firstWhere((item) => item.type == MockClothingData.typeBlazer);
    final skirt = items.firstWhere((item) => item.type == MockClothingData.typeSkirt);
    final sweater = items.firstWhere((item) => item.type == MockClothingData.typeSweater);
    final jacket = items.firstWhere((item) => item.type == MockClothingData.typeJacket);
    final trousers = items.firstWhere((item) => item.type == MockClothingData.typeTrousers);

    return [
      Outfit(
        id: 'outfit1',
        name: outfitCasualSummer,
        items: [dress, jeans],
        savedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Outfit(
        id: 'outfit2',
        name: outfitBusinessProfessional,
        items: [shirt, blazer, trousers],
        savedDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Outfit(
        id: 'outfit3',
        name: outfitEveningElegant,
        items: [skirt, shirt, blazer],
        savedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Outfit(
        id: 'outfit4',
        name: outfitCozyWinter,
        items: [sweater, trousers, jacket],
        savedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Outfit(
        id: 'outfit5',
        name: outfitCasualWeekend,
        items: [jeans, shirt, jacket],
        savedDate: DateTime.now(),
      ),
    ];
  }

  /// Creates a new outfit with the specified parameters
  static Outfit createOutfit({
    required String id,
    required String name,
    required List<ClothingItem> items,
    DateTime? savedDate,
  }) {
    return Outfit(
      id: id,
      name: name,
      items: items,
      savedDate: savedDate ?? DateTime.now(),
    );
  }
}