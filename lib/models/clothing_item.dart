/// Model class for clothing items in the closet
class ClothingItem {
  final String id;
  final String imagePath;
  final String type;
  final String material;
  final String color;
  final String style;
  final String description;
  final bool isEditable;
  final bool isPublic;

  const ClothingItem({
    required this.id,
    required this.imagePath,
    required this.type,
    required this.material,
    required this.color,
    required this.style,
    required this.description,
    this.isEditable = true,
    this.isPublic = false,
  });

  /// Creates a copy of this clothing item with updated fields
  ClothingItem copyWith({
    String? id,
    String? imagePath,
    String? type,
    String? material,
    String? color,
    String? style,
    String? description,
    bool? isEditable,
    bool? isPublic,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      type: type ?? this.type,
      material: material ?? this.material,
      color: color ?? this.color,
      style: style ?? this.style,
      description: description ?? this.description,
      isEditable: isEditable ?? this.isEditable,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  /// Converts this clothing item to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'type': type,
      'material': material,
      'color': color,
      'style': style,
      'description': description,
      'isPublic': isPublic,
    };
  }

  /// Creates a ClothingItem from a JSON object
  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      type: json['type'] as String,
      material: json['material'] as String,
      color: json['color'] as String,
      style: json['style'] as String,
      description: json['description'] as String,
      isPublic: json['public'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClothingItem &&
        id == other.id &&
        imagePath == other.imagePath &&
        type == other.type &&
        material == other.material &&
        color == other.color &&
        style == other.style &&
        description == other.description &&
        isEditable == other.isEditable &&
        isPublic == other.isPublic;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      imagePath,
      type,
      material,
      color,
      style,
      description,
      isEditable,
      isPublic,
    );
  }
}

