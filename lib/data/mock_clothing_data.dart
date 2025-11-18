import '../models/clothing_item.dart';

/// Mock data for clothing items
class MockClothingData {
  // Predefined constants for clothing types
  static const String typeDress = 'Dress';
  static const String typeShirt = 'Shirt';
  static const String typeJeans = 'Jeans';
  static const String typeBlazer = 'Blazer';
  static const String typeSkirt = 'Skirt';
  static const String typeSweater = 'Sweater';
  static const String typeJacket = 'Jacket';
  static const String typeTrousers = 'Trousers';

  // Predefined constants for materials
  static const String materialCotton = 'Cotton';
  static const String materialLinen = 'Linen';
  static const String materialDenim = 'Denim';
  static const String materialWool = 'Wool';
  static const String materialSilk = 'Silk';
  static const String materialCashmere = 'Cashmere';
  static const String materialLeather = 'Leather';
  static const String materialChino = 'Chino';

  // Predefined constants for colors
  static const String colorBlue = 'Blue';
  static const String colorWhite = 'White';
  static const String colorBlack = 'Black';
  static const String colorRed = 'Red';
  static const String colorGray = 'Gray';
  static const String colorBrown = 'Brown';
  static const String colorKhaki = 'Khaki';

  // Predefined constants for styles
  static const String styleCasual = 'Casual';
  static const String styleFormal = 'Formal';
  static const String styleSkinny = 'Skinny';
  static const String styleClassic = 'Classic';
  static const String stylePencil = 'Pencil';
  static const String styleOversized = 'Oversized';
  static const String styleBiker = 'Biker';
  static const String styleStraight = 'Straight';

  static const List<ClothingItem> items = [
    ClothingItem(
      id: '1',
      imagePath: 'assets/images/clothes/dress.png',
      type: typeDress,
      material: materialCotton,
      color: colorBlue,
      style: styleCasual,
      description: 'A comfortable summer dress.',
    ),
    ClothingItem(
      id: '2',
      imagePath: 'assets/images/clothes/shirt.png',
      type: typeShirt,
      material: materialLinen,
      color: colorWhite,
      style: styleFormal,
      description: 'A crisp white linen shirt.',
    ),
    ClothingItem(
      id: '3',
      imagePath: 'assets/images/clothes/jeans.png',
      type: typeJeans,
      material: materialDenim,
      color: colorBlue,
      style: styleSkinny,
      description: 'Dark wash skinny jeans.',
    ),
    ClothingItem(
      id: '4',
      imagePath: 'assets/images/clothes/blazer.png',
      type: typeBlazer,
      material: materialWool,
      color: colorBlack,
      style: styleClassic,
      description: 'A versatile black blazer.',
    ),
    ClothingItem(
      id: '5',
      imagePath: 'assets/images/clothes/skirt.png',
      type: typeSkirt,
      material: materialSilk,
      color: colorRed,
      style: stylePencil,
      description: 'A silk pencil skirt.',
    ),
    ClothingItem(
      id: '6',
      imagePath: 'assets/images/clothes/sweater.png',
      type: typeSweater,
      material: materialCashmere,
      color: colorGray,
      style: styleOversized,
      description: 'A cozy gray cashmere sweater.',
    ),
    ClothingItem(
      id: '7',
      imagePath: 'assets/images/clothes/jacket.png',
      type: typeJacket,
      material: materialLeather,
      color: colorBrown,
      style: styleBiker,
      description: 'A brown leather biker jacket.',
    ),
    ClothingItem(
      id: '8',
      imagePath: 'assets/images/clothes/trousers.png',
      type: typeTrousers,
      material: materialChino,
      color: colorKhaki,
      style: styleStraight,
      description: 'Khaki straight-leg trousers.',
    ),
  ];

  /// Creates a new clothing item with the specified parameters
  static ClothingItem createItem({
    required String id,
    required String imagePath,
    required String type,
    required String material,
    required String color,
    required String style,
    required String description,
  }) {
    return ClothingItem(
      id: id,
      imagePath: imagePath,
      type: type,
      material: material,
      color: color,
      style: style,
      description: description,
    );
  }
}

