import 'clothing_item.dart';

/// Model class for saved outfits
class Outfit {
  final String id;
  final String name;
  final List<ClothingItem> items;
  final DateTime savedDate;

  const Outfit({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Outfit &&
        id == other.id &&
        name == other.name &&
        items.length == other.items.length &&
        _listsEqual(items, other.items) &&
        savedDate == other.savedDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      Object.hashAll(items),
      savedDate,
    );
  }

  /// Helper method to compare two lists of clothing items
  static bool _listsEqual(List<ClothingItem> a, List<ClothingItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

