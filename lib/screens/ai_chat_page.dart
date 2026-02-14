import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/ai_service.dart';
import '../services/data_service.dart';
import '../services/weather_service.dart';
import '../services/background_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/outfit_preview.dart';
import '../widgets/weather_module.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';

/// AI Chatbot Outfit Recommendation Screen
/// Implements the new "Neo-Glass" UI design
class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AIService _aiService;
  StreamSubscription? _itemSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aiService = context.read<AIService>();
      final dataService = context.read<DataService>();

      _itemSubscription = dataService.itemChangeStream.listen((_) {
        if (mounted) _resetChat();
      });

      _aiService.addListener(_scrollDown);
      
      // 1. Show welcome message immediately (static)
      _aiService.startChat(); 

      // 2. Fetch context (weather/closet) in background and update silently
      _initializeChatWithWeather().then((_) => _checkForDailyOutfit());
    });
  }

  Future<void> _checkForDailyOutfit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dailyOutfitText = prefs.getString(keyDailyOutfitReady);
      if (dailyOutfitText != null && dailyOutfitText.isNotEmpty) {
        await prefs.remove(keyDailyOutfitReady);
        if (mounted) _aiService.injectBotResponse(dailyOutfitText);
      }
    } catch (e) {
      debugPrint('Error checking daily outfit: $e');
    }
  }

  Future<void> _initializeChatWithWeather() async {
    final dataService = context.read<DataService>();
    String? weatherString;
    try {
      final weatherService = context.read<WeatherService>();
      final weatherData = await weatherService.getCurrentWeather();
      if (weatherData.isNotEmpty) {
        weatherString = "Temp: ${weatherData['current_temp']}${weatherData['unit']}, "
            "Hi: ${weatherData['max_temp']}, Lo: ${weatherData['min_temp']}";
      }
    } catch (e) {
      debugPrint("Weather fetch failed: $e");
    }

    if (!mounted) return;
    // Update context silently for future messages
    _aiService.updateContext(
      dataService.clothingItems.where((item) => item.isClean).toList(),
      dataService.userProfile,
      weatherInfo: weatherString
    );
  }

  void _resetChat() {
    _aiService.resetChat();
    _textController.clear();
    // Restart logic
    _aiService.startChat();
    _initializeChatWithWeather();
  }

  void _scrollDown() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      _aiService.sendMessage(_textController.text.trim());
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _itemSubscription?.cancel();
    try {
      _aiService.removeListener(_scrollDown);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<DataService>().userProfile;
    final userName = userProfile.name.isNotEmpty ? userProfile.name : 'User';

    return Stack(
      children: [
        // Main Scrollable Content
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 1. Header & Weather
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar placeholder (optional, implied by design)
                        // Container(
                        //   width: 60, height: 60,
                        //   decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                        // ),
                        // const SizedBox(height: 16),
                        Text('Hello, $userName!', style: AppText.display),
                        Text('What shall we wear?', style: AppText.subtitle),
                      ],
                    ),
                    const WeatherModule(), // Floating circular badge
                  ],
                ),
              ),
            ),

            // 2. Chat List
            Consumer<AIService>(
              builder: (context, aiService, child) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final message = aiService.messages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: Column(
                          children: [
                            ChatBubble(
                              message: message.text,
                              isUserMessage: message.isUser,
                              shouldAnimate: !message.isUser && !message.hasAnimated,
                              onAnimationComplete: () => aiService.markMessageAsAnimated(index),
                            ),
                            if (!message.isUser && message.imagePaths != null && message.imagePaths!.isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(top: 12.0),
                                 child: OutfitPreview(
                                    imagePaths: message.imagePaths!, 
                                    itemIds: message.itemIds ?? [],
                                    outfitName: message.outfitName,
                                 ),
                               ),
                          ],
                        ),
                      );
                    },
                    childCount: aiService.messages.length,
                  ),
                );
              },
            ),

            // 3. Bottom Spacer to clear Input Pill + Nav Bar
            // Nav Bar ~ 100px, Input Pill ~ 80px + padding
            const SliverToBoxAdapter(child: SizedBox(height: 220)),
          ],
        ),

        // 4. Input Pill (Floating at bottom)
        Positioned(
          bottom: 120, // Positioned above the Bottom Nav Bar (which has height ~100 including padding)
          left: 20,
          right: 20,
          child: _InputPill(
            controller: _textController,
            onSend: _sendMessage,
            isLoading: context.select<AIService, bool>((s) => s.isLoading),
          ),
        ),
      ],
    );
  }
}

class _InputPill extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const _InputPill({
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: 80,
      width: double.infinity,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      blur: 20,
      opacity: 0.1, // Darker glass
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: AppText.title.copyWith(color: AppColors.accent),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: "find your outfit",
                  hintStyle: AppText.title.copyWith(color: AppColors.accent.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            
            // Send Button Circle
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                  color: Colors.white10,
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
