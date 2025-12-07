import 'package:flutter/foundation.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/friend.dart';
import '../data/mock_clothing_data.dart';
import '../data/mock_outfit_data.dart';
import '../data/mock_friends_data.dart';

/// Service class to manage all application data
class DataService extends ChangeNotifier {
  List<ClothingItem> _clothingItems = [];
  List<Outfit> _outfits = [];
  List<Friend> _friends = [];
  List<ClothingItem> _filteredClothingItems = [];

  List<ClothingItem> get clothingItems => _clothingItems;
  List<Outfit> get outfits => _outfits;
  List<Friend> get friends => _friends;
  List<ClothingItem> get filteredClothingItems => _filteredClothingItems;

  DataService() {
    _initializeData();
  }

  /// Initialize data from mock sources
  void _initializeData() {
    _clothingItems = List.from(MockClothingData.items);
    _outfits = MockOutfitData.getOutfits();
    _friends = List.from(mockFriends);
    _filteredClothingItems = List.from(_clothingItems);
    notifyListeners();
  }

  /// Add a new clothing item
  void addClothingItem(ClothingItem item) {
    _clothingItems.add(item);
    _filteredClothingItems = List.from(_clothingItems);
    notifyListeners();
  }

  /// Remove a clothing item by ID
  void removeClothingItem(String id) {
    _clothingItems.removeWhere((item) => item.id == id);
    _filteredClothingItems = List.from(_clothingItems);
    notifyListeners();
  }

  /// Update a clothing item
  void updateClothingItem(ClothingItem updatedItem) {
    final index = _clothingItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _clothingItems[index] = updatedItem;
      _filteredClothingItems = List.from(_clothingItems);
      notifyListeners();
    }
  }

  /// Filter clothing items by type
  void filterClothingItemsByType(String? type) {
    if (type == null || type.isEmpty) {
      _filteredClothingItems = List.from(_clothingItems);
    } else {
      _filteredClothingItems = _clothingItems
          .where((item) => item.type.toLowerCase().contains(type.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Add a new outfit
  void addOutfit(Outfit outfit) {
    _outfits.add(outfit);
    notifyListeners();
  }

  /// Update an existing outfit
  void updateOutfit(Outfit updatedOutfit) {
    final index = _outfits.indexWhere((outfit) => outfit.id == updatedOutfit.id);
    if (index != -1) {
      _outfits[index] = updatedOutfit;
      notifyListeners();
    }
  }

  /// Remove an outfit by ID
  void removeOutfit(String id) {
    _outfits.removeWhere((outfit) => outfit.id == id);
    notifyListeners();
  }

  /// Get clothing items by type
  List<ClothingItem> getClothingItemsByType(String type) {
    return _clothingItems.where((item) => item.type == type).toList();
  }

  /// Get clothing items by color
  List<ClothingItem> getClothingItemsByColor(String color) {
    return _clothingItems.where((item) => item.color == color).toList();
  }

  /// Get clothing items by material
  List<ClothingItem> getClothingItemsByMaterial(String material) {
    return _clothingItems.where((item) => item.material == material).toList();
  }

  /// Remove a friend by ID
  void removeFriend(String id) {
    _friends.removeWhere((friend) => friend.id == id);
    notifyListeners();
  }
}