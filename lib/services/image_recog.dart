import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../config/app_constants.dart';
import '../models/clothing_item.dart';
import 'prompts.dart';

// Service responsible for analyzing images of clothing items using a generative AI model.
class ImageRecognitionService {
  final GenerativeModel _model;
  final Uuid _uuid = const Uuid();

  // Initializes the service and the generative model.
  // It uses the model specified in AppConstants, which is suitable for image analysis.
  // An API key can be provided, otherwise it falls back to the one in AppConstants.
  ImageRecognitionService({String? apiKey})
      : _model = GenerativeModel(
          model: AppConstants.geminiModel,
          apiKey: apiKey ?? AppConstants.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  // Analyzes a single image file and returns a ClothingItem object.
  // Returns null if the image cannot be processed or if an error occurs.
  Future<ClothingItem?> recognizeImage(XFile imageFile) async {
    try {
      // 1. Read the image file into a byte array.
      final imageBytes = await imageFile.readAsBytes();
      final prompt = AppPrompts.imageRecognitionPrompt;

      // 2. Prepare the content for the API request.
      // This includes the text prompt and the image data.
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      // 3. Send the request to the generative AI model.
      final response = await _model.generateContent(content);
      final jsonString = response.text;

      // 4. Parse the JSON response from the model.
      if (jsonString != null) {
        final jsonResponse = jsonDecode(jsonString) as Map<String, dynamic>;
        
        // 5. Create a new ClothingItem with a unique ID and the parsed data.
        return ClothingItem(
          id: _uuid.v4(),
          imagePath: imageFile.path,
          type: jsonResponse['type'] as String,
          color: jsonResponse['color'] as String,
          material: jsonResponse['material'] as String,
          style: jsonResponse['style'] as String,
          description: jsonResponse['description'] as String,
        );
      }
    } catch (e) {
      // Error handling: If anything goes wrong (e.g., API key issue, network error,
      // invalid JSON), print the error and return null.
      debugPrint('Error recognizing image: $e');
      return null;
    }
    return null;
  }
}