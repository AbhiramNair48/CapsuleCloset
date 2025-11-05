import 'clothing_item.dart';

class Friend {
  final String id;
  final String name;
  final List<ClothingItem> previewItems;
  final List<ClothingItem> closetItems;

  const Friend({
    required this.id,
    required this.name,
    required this.previewItems,
    required this.closetItems,
  });
}