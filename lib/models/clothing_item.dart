/// Model class for clothing items in the closet
class ClothingItem {
  final String id;
  final String imagePath;
  final String type;
  final String material;
  final String color;
  final String style;
  final String description;

  const ClothingItem({
    required this.id,
    required this.imagePath,
    required this.type,
    required this.material,
    required this.color,
    required this.style,
    required this.description,
  });
}

