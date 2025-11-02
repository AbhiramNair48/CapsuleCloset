import '../models/clothing_item.dart';

/// Mock data for clothing items
class MockClothingData {
  static const List<ClothingItem> items = [
    ClothingItem(
      id: '1',
      imagePath: 'assets/images/clothes/dress.png',
      type: 'Dress',
      material: 'Cotton',
      color: 'Blue',
      style: 'Casual',
      description: 'A comfortable summer dress.',
    ),
    ClothingItem(
      id: '2',
      imagePath: 'assets/images/clothes/shirt.png',
      type: 'Shirt',
      material: 'Linen',
      color: 'White',
      style: 'Formal',
      description: 'A crisp white linen shirt.',
    ),
    ClothingItem(
      id: '3',
      imagePath: 'assets/images/clothes/jeans.png',
      type: 'Jeans',
      material: 'Denim',
      color: 'Blue',
      style: 'Skinny',
      description: 'Dark wash skinny jeans.',
    ),
    ClothingItem(
      id: '4',
      imagePath: 'assets/images/clothes/blazer.png',
      type: 'Blazer',
      material: 'Wool',
      color: 'Black',
      style: 'Classic',
      description: 'A versatile black blazer.',
    ),
    ClothingItem(
      id: '5',
      imagePath: 'assets/images/clothes/skirt.png',
      type: 'Skirt',
      material: 'Silk',
      color: 'Red',
      style: 'Pencil',
      description: 'A silk pencil skirt.',
    ),
    ClothingItem(
      id: '6',
      imagePath: 'assets/images/clothes/sweater.png',
      type: 'Sweater',
      material: 'Cashmere',
      color: 'Gray',
      style: 'Oversized',
      description: 'A cozy gray cashmere sweater.',
    ),
    ClothingItem(
      id: '7',
      imagePath: 'assets/images/clothes/jacket.png',
      type: 'Jacket',
      material: 'Leather',
      color: 'Brown',
      style: 'Biker',
      description: 'A brown leather biker jacket.',
    ),
    ClothingItem(
      id: '8',
      imagePath: 'assets/images/clothes/trousers.png',
      type: 'Trousers',
      material: 'Chino',
      color: 'Khaki',
      style: 'Straight',
      description: 'Khaki straight-leg trousers.',
    ),
  ];
}

