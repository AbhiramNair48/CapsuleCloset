/// Mock data for friends and their closets
import '../models/clothing_item.dart';
import '../models/friend.dart';

final List<ClothingItem> mockGerbCloset = [
  ClothingItem(
    id: 'g1',
    imagePath: 'assets/images/clothes/shirt.png',
    type: 'top',
    material: 'cotton',
    color: 'white',
    style: 'formal',
    description: 'Classic white button-down shirt',
  ),
  ClothingItem(
    id: 'g2',
    imagePath: 'assets/images/clothes/dogs_tee.jpg',
    type: 'top',
    material: 'cotton',
    color: 'black',
    style: 'casual',
    description: 'I Love Dogs T-shirt',
  ),
  ClothingItem(
    id: 'g3',
    imagePath: 'assets/images/clothes/flex_tee.jpg',
    type: 'top',
    material: 'cotton',
    color: 'black',
    style: 'casual',
    description: 'Flex T-shirt with dinosaur graphic',
  ),
  ClothingItem(
    id: 'g4',
    imagePath: 'assets/images/clothes/flag_tie.jpg',
    type: 'accessory',
    material: 'silk',
    color: 'multi',
    style: 'formal',
    description: 'American Flag pattern tie',
  ),
  ClothingItem(
    id: 'g5',
    imagePath: 'assets/images/clothes/doritos_tee.jpg',
    type: 'top',
    material: 'cotton',
    color: 'blue',
    style: 'casual',
    description: 'Doritos logo t-shirt',
  ),
  ClothingItem(
    id: 'g6',
    imagePath: 'assets/images/clothes/flame_shorts.jpg',
    type: 'bottom',
    material: 'polyester',
    color: 'red',
    style: 'casual',
    description: 'Red flame pattern shorts',
  ),
];

final List<ClothingItem> mockTaraCloset = [
  ClothingItem(
    id: 't1',
    imagePath: 'assets/images/clothes/dress.png',
    type: 'dress',
    material: 'cotton',
    color: 'floral',
    style: 'casual',
    description: 'Summer floral dress',
  ),
  ClothingItem(
    id: 't2',
    imagePath: 'assets/images/clothes/blazer.png',
    type: 'top',
    material: 'wool',
    color: 'navy',
    style: 'formal',
    description: 'Navy blazer',
  ),
];

final List<ClothingItem> mockAlexCloset = [
  ClothingItem(
    id: 'a1',
    imagePath: 'assets/images/clothes/jacket.png',
    type: 'top',
    material: 'leather',
    color: 'black',
    style: 'casual',
    description: 'Classic leather jacket',
  ),
  ClothingItem(
    id: 'a2',
    imagePath: 'assets/images/clothes/jeans.png',
    type: 'bottom',
    material: 'denim',
    color: 'blue',
    style: 'casual',
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