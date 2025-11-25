import '../models/clothing_item.dart';

class InventoryFormatter {
  static String formatInventory(List<ClothingItem> items) {
    if (items.isEmpty) {
      return "The user's closet is currently empty.";
    }

    final buffer = StringBuffer();
    buffer.writeln("--- User's Closet Inventory ---");
    
    for (var item in items) {
      buffer.writeln("Item ID: ${item.id}");
      buffer.writeln("  - Type: ${item.type}");
      buffer.writeln("  - Material: ${item.material}");
      buffer.writeln("  - Color: ${item.color}");
      buffer.writeln("  - Style: ${item.style}");
      buffer.writeln("  - Description: ${item.description}");
      buffer.writeln("  - Image Path: ${item.imagePath}");
      buffer.writeln(""); // Empty line between items
    }
    
    buffer.writeln("-------------------------------");
    return buffer.toString();
  }
}
