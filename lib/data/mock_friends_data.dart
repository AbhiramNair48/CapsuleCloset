/// Mock data for friends and their closets
library;
import '../models/clothing_item.dart';
import '../models/friend.dart';

// Constants for types
const String typeTop = 'top';
const String typeBottom = 'bottom';
const String typeAccessory = 'accessory';
const String typeDress = 'dress';

// Constants for materials  
const String materialCotton = 'cotton';
const String materialSilk = 'silk';
const String materialWool = 'wool';
const String materialLeather = 'leather';
const String materialDenim = 'denim';
const String materialPolyester = 'polyester';

// Constants for colors
const String colorWhite = 'white';
const String colorBlack = 'black';
const String colorBlue = 'blue';
const String colorMulti = 'multi';
const String colorFloral = 'floral';
const String colorNavy = 'navy';
const String colorRed = 'red';

// Constants for styles
const String styleFormal = 'formal';
const String styleCasual = 'casual';

final List<ClothingItem> mockGerbCloset = [
  ClothingItem(
    id: 'g1',
    imagePath: 'assets/images/clothes/shirt.png',
    type: typeTop,
    material: materialCotton,
    color: colorWhite,
    style: styleFormal,
    description: 'Classic white button-down shirt',
  ),
  ClothingItem(
    id: 'g2',
    imagePath: 'assets/images/clothes/dogs_tee.jpg',
    type: typeTop,
    material: materialCotton,
    color: colorBlack,
    style: styleCasual,
    description: 'I Love Dogs T-shirt',
  ),
  ClothingItem(
    id: 'g3',
    imagePath: 'assets/images/clothes/flex_tee.jpg',
    type: typeTop,
    material: materialCotton,
    color: colorBlack,
    style: styleCasual,
    description: 'Flex T-shirt with dinosaur graphic',
  ),
  ClothingItem(
    id: 'g4',
    imagePath: 'assets/images/clothes/flag_tie.jpg',
    type: typeAccessory,
    material: materialSilk,
    color: colorMulti,
    style: styleFormal,
    description: 'American Flag pattern tie',
  ),
  ClothingItem(
    id: 'g5',
    imagePath: 'assets/images/clothes/doritos_tee.jpg',
    type: typeTop,
    material: materialCotton,
    color: colorBlue,
    style: styleCasual,
    description: 'Doritos logo t-shirt',
  ),
  ClothingItem(
    id: 'g6',
    imagePath: 'assets/images/clothes/flame_shorts.jpg',
    type: typeBottom,
    material: materialPolyester,
    color: colorRed,
    style: styleCasual,
    description: 'Red flame pattern shorts',
  ),
];

final List<ClothingItem> mockTaraCloset = [
  ClothingItem(
    id: 't1',
    imagePath: 'assets/images/clothes/dress.png',
    type: typeDress,
    material: materialCotton,
    color: colorFloral,
    style: styleCasual,
    description: 'Summer floral dress',
  ),
  ClothingItem(
    id: 't2',
    imagePath: 'assets/images/clothes/blazer.png',
    type: typeTop,
    material: materialWool,
    color: colorNavy,
    style: styleFormal,
    description: 'Navy blazer',
  ),
];

final List<ClothingItem> mockAlexCloset = [
  ClothingItem(
    id: 'a1',
    imagePath: 'assets/images/clothes/jacket.png',
    type: typeTop,
    material: materialLeather,
    color: colorBlack,
    style: styleCasual,
    description: 'Classic leather jacket',
  ),
  ClothingItem(
    id: 'a2',
    imagePath: 'assets/images/clothes/jeans.png',
    type: typeBottom,
    material: materialDenim,
    color: colorBlue,
    style: styleCasual,
    description: 'Distressed blue jeans',
  ),
];

final List<Friend> mockFriends = [
  Friend(
    id: '1',
    name: "Gerb's Closet",
    previewItems: mockGerbCloset.take(4).toList(),
    closetItems: mockGerbCloset,
  ),
  Friend(
    id: '2',
    name: "Tara's Collection",
    previewItems: mockTaraCloset.take(4).toList(),
    closetItems: mockTaraCloset,
  ),
  Friend(
    id: '3',
    name: "Alex's Wardrobe",
    previewItems: mockAlexCloset.take(4).toList(),
    closetItems: mockAlexCloset,
  ),
];

/// Creates a new friend with the specified parameters
Friend createFriend({
  required String id,
  required String name,
  required List<ClothingItem> closetItems,
}) {
  return Friend(
    id: id,
    name: name,
    previewItems: closetItems.take(4).toList(),
    closetItems: closetItems,
  );
}