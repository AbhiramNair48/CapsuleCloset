import 'dart:convert';
import 'dart:async';
import 'package:capsule_closet_app/config/app_constants.dart';
import 'package:capsule_closet_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/friend.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../models/pending_friend_request.dart';
import 'dart:io';

import 'package:capsule_closet_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capsule_closet_app/services/notification_service.dart';
import 'package:capsule_closet_app/services/background_service.dart';

/// Service class to manage all application data
class DataService extends ChangeNotifier {
  AuthService? _authService;
  final StorageService _storageService;
  final http.Client _client;
  final _itemChangeController = StreamController<void>.broadcast();

  Stream<void> get itemChangeStream => _itemChangeController.stream;

  List<ClothingItem> _clothingItems = [];
  List<Outfit> _outfits = [];
  List<Friend> _friends = [];
  List<ClothingItem> _filteredClothingItems = [];
  List<PendingFriendRequest> _pendingFriendRequests = [];
  UserProfile _userProfile = const UserProfile();

  List<ClothingItem> get clothingItems => _clothingItems;
  List<Outfit> get outfits => _outfits;
  List<Friend> get friends => _friends;
  List<ClothingItem> get filteredClothingItems => _filteredClothingItems;
  List<ClothingItem> get hamperItems => _clothingItems.where((item) => !item.isClean).toList();
  List<PendingFriendRequest> get pendingFriendRequests => _pendingFriendRequests;
  UserProfile get userProfile => _userProfile;

  DataService(this._authService, {http.Client? httpClient, StorageService? storageService}) 
      : _client = httpClient ?? http.Client(),
        _storageService = storageService ?? StorageService() {
    _authService?.addListener(_onAuthStateChanged);
    _initializeData();
  }

  /// Update the auth service reference (used by ProxyProvider)
  void updateAuth(AuthService auth) {
    if (_authService == auth) return;
    
    _authService?.removeListener(_onAuthStateChanged);
    _authService = auth;
    _authService?.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  @override
  void dispose() {
    _authService?.removeListener(_onAuthStateChanged);
    _itemChangeController.close();
    // Don't close client if injected? Or do? usually if we created it (default), we close it.
    // If injected, the caller owns it. 
    _client.close();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (_authService?.isAuthenticated == true && _authService?.currentUser != null) {
      final userId = _authService!.currentUser!['id'];
      _updateProfileFromAuth();
      fetchClothingItems(userId.toString());
      fetchOutfits(userId.toString());
      fetchFriends(userId.toString());
      fetchPendingFriendRequests(userId.toString());
      loadNotificationSettings(userId.toString());
    } else {
      _clearData();
    }
  }

  /// Initialize data. All data is fetched from the backend.
  void _initializeData() {
    // Check if user is already authenticated on startup
    if (_authService?.isAuthenticated == true && _authService?.currentUser != null) {
      final userId = _authService!.currentUser!['id'];
      _updateProfileFromAuth();
      fetchClothingItems(userId.toString());
      fetchOutfits(userId.toString());
      fetchFriends(userId.toString());
      fetchPendingFriendRequests(userId.toString());
      loadNotificationSettings(userId.toString());
    }
  }

  void _updateProfileFromAuth() {
    if (_authService?.currentUser != null) {
      final user = _authService!.currentUser!;
      _userProfile = _userProfile.copyWith(
        name: user['username']?.toString() ?? '',
        gender: user['gender']?.toString() ?? '',
        favoriteStyle: user['favorite_style']?.toString() ?? '',
      );
      notifyListeners();
    }
  }

  /// Caches the current clothing items to SharedPreferences
  Future<void> _cacheClothingItems(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = jsonEncode(_clothingItems.map((e) => e.toJson()).toList());
      await prefs.setString('cached_closet_$userId', itemsJson);
    } catch (e) {
      debugPrint('Error caching closet: $e');
    }
  }

  /// Load notification settings from SharedPreferences
  Future<void> loadNotificationSettings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('dailyNotificationEnabled_$userId') ?? false;
    final time = prefs.getString('dailyNotificationTime_$userId');
    final occasion = prefs.getString('dailyNotificationOccasion_$userId');

    _userProfile = _userProfile.copyWith(
      isDailyNotificationEnabled: isEnabled,
      notificationTime: time,
      notificationOccasion: occasion,
    );
    notifyListeners();
  }

  /// Save notification settings to SharedPreferences and schedule/cancel notification
  Future<void> saveNotificationSettings(bool isEnabled, String? time, String? occasion) async {
    final userId = _authService?.currentUser?['id']?.toString();
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyNotificationEnabled_$userId', isEnabled);
    // Save active user ID for background service
    await prefs.setString('active_user_id', userId);
    
    if (time != null) await prefs.setString('dailyNotificationTime_$userId', time);
    if (occasion != null) await prefs.setString('dailyNotificationOccasion_$userId', occasion);

    _userProfile = _userProfile.copyWith(
      isDailyNotificationEnabled: isEnabled,
      notificationTime: time,
      notificationOccasion: occasion,
    );
    
    notifyListeners();

    if (isEnabled && time != null && occasion != null) {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        // Request permissions if needed
        final hasPermission = await NotificationService().requestPermissions();
        if (hasPermission) {
            await NotificationService().scheduleDailyOutfitNotification(
              hour: hour, 
              minute: minute, 
              occasion: occasion
            );
            
            // Register background task
            await BackgroundService.registerDailyTask(hour, minute);
        } else {
          debugPrint('Notification permissions denied');
        }
      }
    } else {
      await NotificationService().cancelDailyNotification();
      await BackgroundService.cancelTask();
    }
  }
  
  /// Fetches clothing items for the given user from the backend
  Future<void> fetchClothingItems(String userId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/closet?user_id=$userId');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = jsonDecode(response.body);
        _clothingItems = itemsJson.map((json) => ClothingItem.fromJson(json)).toList();
        _filteredClothingItems = _clothingItems.where((item) => item.isClean).toList();
        // Cache the items for background use
        _cacheClothingItems(userId);
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
      final response = await _client.get(url);

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
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = jsonDecode(response.body);
        _friends = itemsJson.map((json) => Friend.fromJson(json)).toList();
        if (kDebugMode) {
          print('Fetched ${_friends.length} friends from backend.');
        }
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

  /// Fetches pending friend requests for the given user from the backend
  Future<void> fetchPendingFriendRequests(String userId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/friends/pending?user_id=$userId');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = jsonDecode(response.body);
        _pendingFriendRequests = itemsJson.map((json) => PendingFriendRequest.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print('Failed to load pending friend requests: ${response.statusCode}');
        }
        _pendingFriendRequests = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching pending friend requests: $e');
      }
      _pendingFriendRequests = [];
    }
    notifyListeners();
  }

  /// Searches for users by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/users/search?q=$query');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = jsonDecode(response.body);
        return usersJson.cast<Map<String, dynamic>>();
      } else {
        if (kDebugMode) {
          print('Failed to search users: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching users: $e');
      }
      return [];
    }
  }

  /// Sends a friend request
  Future<bool> sendFriendRequest(String senderUserEmail, String recipientId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/friends/request');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_email': senderUserEmail, // this is the sender's email
          'friend_id': recipientId, // this is the recipient's id
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to send friend request: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending friend request: $e');
      }
      return false;
    }
  }

  /// Responds to a friend request (accept/reject)
  Future<bool> respondToFriendRequest(String friendshipId, String status) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/friends/request/$friendshipId');
      final response = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        // After accepting/rejecting, refresh pending requests and accepted friends
        final userId = _authService?.currentUser?['id']?.toString();
        if (userId != null) {
          fetchPendingFriendRequests(userId);
          fetchFriends(userId); // Re-fetch accepted friends to update UI
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to respond to friend request: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error responding to friend request: $e');
      }
      return false;
    }
  }

  /// Uploads a new clothing item to the backend (and Firebase Storage)
  Future<ClothingItem?> uploadClothingItem({
    required XFile imageFile,
    required ClothingItem recognizedData,
    required String userId,
  }) async {
    String? downloadUrl;
    try {
      // 1. Upload image to Firebase Storage first
      try {
        downloadUrl = await _storageService.uploadImage(File(imageFile.path));
      } catch (e) {
        if (kDebugMode) print('Firebase upload failed, falling back to local server upload: $e');
        // Continue to try local upload if Firebase fails
      }

      final url = Uri.parse('${AppConstants.baseUrl}/closet/upload');
      final request = http.MultipartRequest('POST', url);

      // 2. Add data fields
      request.fields['user_id'] = userId;
      request.fields['type'] = recognizedData.type;
      request.fields['color'] = recognizedData.color;
      request.fields['material'] = recognizedData.material;
      request.fields['style'] = recognizedData.style;
      request.fields['description'] = recognizedData.description;
      request.fields['public'] = 'false';

      // 3. Attach image source
      if (downloadUrl != null) {
        // If we have a Firebase URL, send it as a field
        request.fields['img_url'] = downloadUrl;
      } else {
        // If Firebase failed (or skipped), try uploading the file directly to backend (legacy/fallback)
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path, filename: imageFile.name));
      }

      final response = await _client.send(request);

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final newItem = ClothingItem.fromJson(jsonDecode(responseBody));
        
        // Add the new item to the local state
        addClothingItem(newItem);
        
        return newItem;
      } else {
        if (kDebugMode) {
          print('Failed to upload item: ${response.statusCode}');
          final responseBody = await response.stream.bytesToString();
          print('Response body: $responseBody');
        }
        
        // CLEANUP: If backend failed and we uploaded to Firebase, delete the image
        if (downloadUrl != null) {
          await _storageService.deleteImage(downloadUrl);
        }
        
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading item: $e');
      }
      
      // CLEANUP: If exception occurred and we uploaded to Firebase, delete the image
      if (downloadUrl != null) {
          await _storageService.deleteImage(downloadUrl);
      }
      
      return null;
    }
  }

  Future<void> updateClothingItemPublicStatus(String itemId, bool isPublic) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/closet/$itemId/public');
      final response = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'public': isPublic}),
      );

      if (response.statusCode == 200) {
        // Update local state
        final index = _clothingItems.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          final item = _clothingItems[index];
          _clothingItems[index] = item.copyWith(isPublic: isPublic);
          notifyListeners();

          // Update Firebase metadata if image is on Firebase
          if (item.imagePath.startsWith('http') && !item.imagePath.contains('10.0.2.2')) {
             await _storageService.updateImageMetadata(item.imagePath, isPublic);
          }
        }
      } else {
        // Handle error, maybe show a snackbar or log it
        if (kDebugMode) {
          print('Failed to update public status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating public status: $e');
      }
    }
  }
  
  void _clearData() {
    _clothingItems = [];
    _filteredClothingItems = [];
    _outfits = [];
    _friends = [];
    _pendingFriendRequests = [];
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    notifyListeners();

    try {
      final userId = _authService?.currentUser?['id'];
      if (userId == null) return;

      final url = Uri.parse('${AppConstants.baseUrl}/users/profile');
      await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userId,
          'username': profile.name,
          'gender': profile.gender,
          'favorite_style': profile.favoriteStyle,
        }),
      );
    } catch (e) {
      if (kDebugMode) print('Error updating profile on backend: $e');
    }
  }

  /// Add a new clothing item
  void addClothingItem(ClothingItem item) {
    _clothingItems.add(item);
    _filteredClothingItems = List.from(_clothingItems);
    _itemChangeController.add(null);
    notifyListeners();
  }

  /// Remove a clothing item by ID
  Future<void> removeClothingItem(String id) async {
    try {
      // Find the item first to get its image URL
      final itemToDelete = _clothingItems.firstWhere((item) => item.id == id, orElse: () => 
        const ClothingItem(id: '', imagePath: '', type: '', material: '', color: '', style: '', description: '')
      );

      // If the item exists and has a valid image path, delete it from storage
      if (itemToDelete.id.isNotEmpty && itemToDelete.imagePath.isNotEmpty) {
        // We attempt to delete the image from storage. 
        // Even if this fails (e.g. image already gone), we proceed to delete the record from backend.
        await _storageService.deleteImage(itemToDelete.imagePath);
      }

      final url = Uri.parse('${AppConstants.baseUrl}/closet/$id');
      final response = await _client.delete(url);

      if (response.statusCode == 200) {
        _clothingItems.removeWhere((item) => item.id == id);
        _filteredClothingItems = List.from(_clothingItems);
        _itemChangeController.add(null);
        notifyListeners();
      } else {
        if (kDebugMode) {
          print('Failed to delete clothing item: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting clothing item: $e');
      }
    }
  }

  /// Update a clothing item
  Future<void> updateClothingItem(ClothingItem updatedItem) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/closet/${updatedItem.id}');
      final response = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedItem.toJson()), // Send all relevant fields
      );

      if (response.statusCode == 200) {
        final index = _clothingItems.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          _clothingItems[index] = updatedItem;
          _filteredClothingItems = List.from(_clothingItems);
          notifyListeners();
        }
      } else {
        if (kDebugMode) {
          print('Failed to update clothing item: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating clothing item: $e');
      }
    }
  }

  /// Filter clothing items by type
  void filterClothingItemsByType(String? type) {
    if (type == null || type.isEmpty) {
      _filteredClothingItems = _clothingItems.where((item) => item.isClean).toList();
    } else {
      _filteredClothingItems = _clothingItems
          .where((item) => item.isClean && item.type.toLowerCase().contains(type.toLowerCase()))
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

  Future<void> markItemDirty(String itemId) async {
    final item = _clothingItems.firstWhere((element) => element.id == itemId, orElse: () => const ClothingItem(id: '', imagePath: '', type: '', material: '', color: '', style: '', description: ''));
    if (item.id.isNotEmpty) {
      await updateClothingItem(item.copyWith(isClean: false));
    }
  }

  Future<void> markItemClean(String itemId) async {
    final item = _clothingItems.firstWhere((element) => element.id == itemId, orElse: () => const ClothingItem(id: '', imagePath: '', type: '', material: '', color: '', style: '', description: ''));
    if (item.id.isNotEmpty) {
      await updateClothingItem(item.copyWith(isClean: true));
    }
  }

  Future<void> markAllClean() async {
    final dirtyItems = _clothingItems.where((item) => !item.isClean).toList();
    for (var item in dirtyItems) {
      await updateClothingItem(item.copyWith(isClean: true));
    }
  }

  /// Remove a friend by ID
  void removeFriend(String id) {
    _friends.removeWhere((friend) => friend.id == id);
    notifyListeners();
  }
}