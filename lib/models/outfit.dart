import 'clothing_item.dart';

/// Model class for saved outfits
class Outfit {
  final String id;
  String name;
  final List<ClothingItem> items;
  final DateTime savedDate;

  Outfit({
    required this.id,
    required this.name,
    required this.items,
    required this.savedDate,
  });

  /// Creates a copy of this outfit with updated fields
  Outfit copyWith({
    String? name,
  }) {
    return Outfit(
      id: id,
      name: name ?? this.name,
      items: items,
      savedDate: savedDate,
    );
  }
}

