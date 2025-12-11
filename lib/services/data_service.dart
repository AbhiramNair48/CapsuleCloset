import 'dart:convert';
import 'package:capsule_closet_app/config/app_constants.dart';
import 'package:capsule_closet_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/friend.dart';
import '../models/user_profile.dart';

/// Service class to manage all application data
class DataService extends ChangeNotifier {
  final AuthService? _authService;

  List<ClothingItem> _clothingItems = [];
  List<Outfit> _outfits = [];
  List<Friend> _friends = [];
  List<ClothingItem> _filteredClothingItems = [];
  UserProfile _userProfile = const UserProfile();

  List<ClothingItem> get clothingItems => _clothingItems;
  List<Outfit> get outfits => _outfits;
  List<Friend> get friends => _friends;
  List<ClothingItem> get filteredClothingItems => _filteredClothingItems;
  UserProfile get userProfile => _userProfile;

  DataService(this._authService) {
    _authService?.addListener(_onAuthStateChanged);
    _initializeData();
  }

  @override
  void dispose() {
    _authService?.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (_authService?.isAuthenticated == true && _authService?.currentUser != null) {
      final userId = _authService!.currentUser!['id'];
      fetchClothingItems(userId.toString());
      fetchOutfits(userId.toString());
      fetchFriends(userId.toString());
    } else {
      _clearData();
    }
  }

  /// Initialize data. All data is fetched from the backend.
  void _initializeData() {
    // Check if user is already authenticated on startup
    if (_authService?.isAuthenticated == true && _authService?.currentUser != null) {
      final userId = _authService!.currentUser!['id'];
      fetchClothingItems(userId.toString());
      fetchOutfits(userId.toString());
      fetchFriends(userId.toString());
    }
  }
  
  /// Fetches clothing items for the given user from the backend
  Future<void> fetchClothingItems(String userId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/closet?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = jsonDecode(response.body);
        _clothingItems = itemsJson.map((json) => ClothingItem.fromJson(json)).toList();
        _filteredClothingItems = List.from(_clothingItems);
      } else {
        if (kDebugMode) {
          print('Failed to load clothing items: ${response.statusCode}');
        }
        _clothingItems = [];
        _filteredClothingItems = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching clothing items: $e');
      }
      _clothingItems = [];
      _filteredClothingItems = [];
    }
    notifyListeners();
  }

  /// Fetches outfits for the given user from the backend
  Future<void> fetchOutfits(String userId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/outfits?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = jsonDecode(response.body);
        _outfits = itemsJson.map((json) => Outfit.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print('Failed to load outfits: ${response.statusCode}');
        }
        _outfits = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching outfits: $e');
      }
      _outfits = [];
    }
    notifyListeners();
  }

  /// Fetches friends for the given user from the backend
  Future<void> fetchFriends(String userId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/friends?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = jsonDecode(response.body);
        _friends = itemsJson.map((json) => Friend.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print('Failed to load friends: ${response.statusCode}');
        }
        _friends = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching friends: $e');
      }
      _friends = [];
    }
    notifyListeners();
  }
  
  void _clearData() {
    _clothingItems = [];
    _filteredClothingItems = [];
    _outfits = [];
    _friends = [];
    notifyListeners();
  }

  /// Update user profile
  void updateUserProfile(UserProfile profile) {
    _userProfile = profile;
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
