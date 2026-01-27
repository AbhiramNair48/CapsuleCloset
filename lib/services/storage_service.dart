import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class StorageService {
  // Use getters to lazily access instances. This prevents crashes in tests where Firebase is not initialized.
  FirebaseStorage get _storage => FirebaseStorage.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Uploads an image file to Firebase Storage with compression
  /// Returns the download URL string
  Future<String?> uploadImage(File file, {String? folder}) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) print('Upload failed: User not logged in');
        throw Exception('User not logged in');
      }

      // 1. Compress the image
      final File? compressedFile = await _compressImage(file);
      if (compressedFile == null) {
        if (kDebugMode) print('Compression failed');
        return null; // Or throw generic error
      }

      // 2. Create a unique filename
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      
      // 3. Structure: users/{uid}/{folder}/{filename}
      final String destination = 'users/${user.uid}/${folder ?? "closet"}/$fileName';

      // 4. Create the reference
      final Reference ref = _storage.ref(destination);

      // 5. Create upload task with metadata
      final UploadTask task = ref.putFile(
        compressedFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Optional: Listen to progress if needed in the UI (via a StreamController if we returned a Stream)
      // task.snapshotEvents.listen((TaskSnapshot snapshot) { ... });

      // 6. Wait for completion
      final TaskSnapshot snapshot = await task;
      
      // 7. Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Cleanup compressed file if it's a temp file (flutter_image_compress handles this usually, but good practice to check)
      // For now, we rely on the system to clean up temp dir.

      return downloadUrl;

    } on FirebaseException catch (e) {
      if (kDebugMode) print('Firebase Storage Error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      if (kDebugMode) print('General Upload Error: $e');
      return null;
    }
  }

  /// Delete an image from storage using its URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      if (kDebugMode) print('Deleted image: $imageUrl');
    } catch (e) {
      if (kDebugMode) print('Error deleting image: $e');
      // Non-blocking error - we don't want to stop the UI if cleanup fails
    }
  }

  /// Compress image to reduce size
  Future<File?> _compressImage(File file) async {
    try {
      final String targetPath = '${file.parent.path}/${DateTime.now().millisecondsSinceEpoch}_temp.jpg';
      
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70, // Adjust quality (0-100)
        minWidth: 1024, // Resize to max width
        minHeight: 1024, // Resize to max height
      );
      
      // Convert XFile to File if needed (newer versions return XFile)
      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Compression Error: $e');
      return file; // Fallback to original if compression fails
    }
  }

  /// Update image metadata (e.g., public status)
  Future<void> updateImageMetadata(String imageUrl, bool isPublic) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.updateMetadata(SettableMetadata(
        customMetadata: {'public': isPublic.toString()},
      ));
      if (kDebugMode) print('Updated metadata for $imageUrl: public=$isPublic');
    } catch (e) {
      if (kDebugMode) print('Error updating metadata: $e');
    }
  }
}