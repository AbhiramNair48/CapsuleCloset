import 'clothing_item.dart';

class Friend {
  final String id;
  final String name;
  final List<ClothingItem> previewItems;
  final List<ClothingItem> closetItems;

  Friend({
    required this.id,
    required this.name,
    required List<ClothingItem> previewItems,
    required List<ClothingItem> closetItems,
  })  : previewItems = previewItems.map((item) => item.copyWith(isEditable: false)).toList(),
        closetItems = closetItems.map((item) => item.copyWith(isEditable: false)).toList();

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

  factory Friend.fromJson(Map<String, dynamic> json) {
    var previewList = json['previewItems'] as List;
    List<ClothingItem> previewItems =
        previewList.map((i) => ClothingItem.fromJson(i)).toList();

    var closetList = json['closetItems'] as List;
    List<ClothingItem> closetItems =
        closetList.map((i) => ClothingItem.fromJson(i)).toList();

    return Friend(
      id: json['id'],
      name: json['name'],
      previewItems: previewItems,
      closetItems: closetItems,
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