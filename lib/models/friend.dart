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

  /// Creates a copy of this friend with updated fields
  Friend copyWith({
    String? id,
    String? name,
    List<ClothingItem>? previewItems,
    List<ClothingItem>? closetItems,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      previewItems: previewItems ?? this.previewItems,
      closetItems: closetItems ?? this.closetItems,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friend &&
        id == other.id &&
        name == other.name &&
        previewItems.length == other.previewItems.length &&
        _listsEqual(previewItems, other.previewItems) &&
        closetItems.length == other.closetItems.length &&
        _listsEqual(closetItems, other.closetItems);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      Object.hashAll(previewItems),
      Object.hashAll(closetItems),
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