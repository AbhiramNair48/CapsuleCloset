import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:capsule_closet_app/config/app_constants.dart';
import 'package:capsule_closet_app/models/clothing_item.dart';
import 'package:capsule_closet_app/services/prompts.dart';
import 'package:capsule_closet_app/services/inventory_formatter.dart';
import 'package:flutter/foundation.dart';

const String taskGenerateOutfit = 'generateDailyOutfit';
const String keyDailyOutfitReady = 'daily_outfit_ready';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskGenerateOutfit) {
      try {
        await _generateDailyOutfit();
        return true;
      } catch (e) {
        debugPrint('Background outfit generation failed: $e');
        return false;
      }
    }
    return true;
  });
}

Future<void> _generateDailyOutfit() async {
  final prefs = await SharedPreferences.getInstance();
  
  // 1. Identify User (simple approach: assuming single user or last active user stored)
  // Since SharedPreferences are global to the app, we need to know WHICH user's data to load.
  // We'll store the 'active_user_id' in DataService when saving settings.
  final userId = prefs.getString('active_user_id');
  if (userId == null) {
    debugPrint('No active user ID found for background task.');
    return;
  }

  // 2. Load cached closet
  final closetJson = prefs.getString('cached_closet_$userId');
  if (closetJson == null) {
    debugPrint('No cached closet found for user $userId.');
    return;
  }
  
  final List<dynamic> decodedList = jsonDecode(closetJson);
  final List<ClothingItem> items = decodedList.map((e) => ClothingItem.fromJson(e)).toList();
  
  if (items.isEmpty) {
     debugPrint('Closet is empty.');
     return;
  }

  // 3. Load preferences
  final occasion = prefs.getString('dailyNotificationOccasion_$userId') ?? 'Casual';
  
  // 4. Generate Outfit using Gemini
  final apiKey = AppConstants.geminiLLMApiKey;
  if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
    debugPrint('Gemini API key missing.');
    return;
  }

  final model = GenerativeModel(
    model: AppConstants.geminiModel,
    apiKey: apiKey,
  );

  final inventoryString = InventoryFormatter.formatInventory(items);
  // We can't easily get weather in background without location permission in background 
  // (which is harder to get). We'll omit weather or use a generic "check the weather" prompt.
  
  final prompt = '''
  You are a personal stylist. The user has the following clothes:
  $inventoryString
  
  Please create a $occasion outfit for today.
  ${AppPrompts.stylistSystemPrompt}
  ''';

  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);
  
  final responseText = response.text;
  if (responseText != null) {
    // 5. Save the result
    await prefs.setString(keyDailyOutfitReady, responseText);
    debugPrint('Daily outfit generated and saved in background.');
  }
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static Future<void> registerDailyTask(int hour, int minute) async {
    // Calculate initial delay
    final now = DateTime.now();
    var generationTime = DateTime(now.year, now.month, now.day, hour, minute).subtract(const Duration(minutes: 30));
    
    // If generation time is in the past...
    if (generationTime.isBefore(now)) {
        // Check if the ACTUAL notification time is still in the future (e.g. user set it for 5 mins from now)
        final notificationTime = DateTime(now.year, now.month, now.day, hour, minute);
        if (notificationTime.isAfter(now)) {
             // We are in the "buffer zone". Schedule immediate run.
             generationTime = now;
        } else {
             // Notification time is also past, so schedule for tomorrow's generation time
             generationTime = generationTime.add(const Duration(days: 1));
        }
    }
    
    Duration initialDelay = generationTime.difference(now);
    if (initialDelay.isNegative) {
      initialDelay = Duration.zero;
    }

    await Workmanager().registerPeriodicTask(
      "dailyOutfitTask", 
      taskGenerateOutfit,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: NetworkType.connected, // Needs internet for Gemini
      ),
    );
  }
  
  static Future<void> cancelTask() async {
    await Workmanager().cancelByUniqueName("dailyOutfitTask");
  }
}
