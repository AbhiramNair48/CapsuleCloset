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
  static const String typeShorts = 'Shorts';
  static const String typeFootwear = 'Footwear';
  static const String typeAccessories = 'Accessories';

  // Predefined constants for materials
  static const String materialCotton = 'Cotton';
  static const String materialLinen = 'Linen';
  static const String materialDenim = 'Denim';
  static const String materialWool = 'Wool';
  static const String materialSilk = 'Silk';
  static const String materialCashmere = 'Cashmere';
  static const String materialLeather = 'Leather';
  static const String materialChino = 'Chino';
  static const String materialSynthetic = 'Synthetic';
  static const String materialCanvas = 'Canvas';

  // Predefined constants for colors
  static const String colorBlue = 'Blue';
  static const String colorWhite = 'White';
  static const String colorBlack = 'Black';
  static const String colorRed = 'Red';
  static const String colorGray = 'Gray';
  static const String colorBrown = 'Brown';
  static const String colorKhaki = 'Khaki';
  static const String colorGreen = 'Green';

  // Predefined constants for styles
  static const String styleCasual = 'Casual';
  static const String styleFormal = 'Formal';
  static const String styleSkinny = 'Skinny';
  static const String styleClassic = 'Classic';
  static const String stylePencil = 'Pencil';
  static const String styleOversized = 'Oversized';
  static const String styleBiker = 'Biker';
  static const String styleStraight = 'Straight';
  static const String styleBaggy = 'Baggy';
  static const String styleButtonUp = 'Button-up';
  static const String stylePolo = 'Polo';
  static const String stylePuffer = 'Puffer';
  static const String styleQuarterZip = 'Quarter-zip';
  static const String styleTie = 'Tie';
  static const String styleCargo = 'Cargo';
  static const String styleZipUp = 'Zip-up';

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
    // New clothing items
    ClothingItem(
      id: '9',
      imagePath: 'assets/images/clothes/baggy_jeans.jpg',
      type: typeJeans,
      material: materialDenim,
      color: colorBlue,
      style: styleBaggy,
      description: 'Comfortable baggy fit jeans for a relaxed look.',
    ),
    ClothingItem(
      id: '10',
      imagePath: 'assets/images/clothes/boots.jpg',
      type: typeFootwear,
      material: materialLeather,
      color: colorBrown,
      style: styleCasual,
      description: 'Stylish brown leather boots for any occasion.',
    ),
    ClothingItem(
      id: '11',
      imagePath: 'assets/images/clothes/cargo_pants.jpg',
      type: typeTrousers,
      material: materialCotton,
      color: colorBlack,
      style: styleCargo,
      description: 'Practical black cargo pants with multiple pockets.',
    ),
    ClothingItem(
      id: '12',
      imagePath: 'assets/images/clothes/cargo_shorts.jpg',
      type: typeShorts,
      material: materialCotton,
      color: colorGreen,
      style: styleCargo,
      description: 'Comfortable forest Green cargo shorts for warm weather.',
    ),
    ClothingItem(
      id: '13',
      imagePath: 'assets/images/clothes/green_buttonup.jpg',
      type: typeShirt,
      material: materialCotton,
      color: colorGreen,
      style: styleButtonUp,
      description: 'A stylish green button-up shirt for casual or semi-formal looks.',
    ),
    ClothingItem(
      id: '14',
      imagePath: 'assets/images/clothes/polo_shirt.jpg',
      type: typeShirt,
      material: materialCotton,
      color: colorBlue,
      style: stylePolo,
      description: 'Classic navy blue polo shirt for a smart-casual appearance.',
    ),
    ClothingItem(
      id: '15',
      imagePath: 'assets/images/clothes/puffer_jacket.jpg',
      type: typeJacket,
      material: materialSynthetic,
      color: colorBlue,
      style: stylePuffer,
      description: 'Warm navy blue puffer jacket for cold weather.',
    ),
    ClothingItem(
      id: '16',
      imagePath: 'assets/images/clothes/quarterzip.jpg',
      type: typeSweater,
      material: materialCotton,
      color: colorBlue,
      style: styleQuarterZip,
      description: 'Cozy light blue quarter-zip sweater for layering.',
    ),
    ClothingItem(
      id: '17',
      imagePath: 'assets/images/clothes/red_tie.jpg',
      type: typeAccessories,
      material: materialSilk,
      color: colorRed,
      style: styleTie,
      description: 'Elegant red silk tie for formal occasions.',
    ),
    ClothingItem(
      id: '18',
      imagePath: 'assets/images/clothes/white_shoes.jpg',
      type: typeFootwear,
      material: materialCanvas,
      color: colorWhite,
      style: styleCasual,
      description: 'Clean white canvas shoes for a fresh look.',
    ),
    ClothingItem(
      id: '19',
      imagePath: 'assets/images/clothes/zipup_jacket.jpg',
      type: typeJacket,
      material: materialSynthetic,
      color: colorWhite,
      style: styleZipUp,
      description: 'Functional off-white zip-up jacket for outdoor activities.',
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

