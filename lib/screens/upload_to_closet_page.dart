import 'dart:io';
import 'package:capsule_closet_app/services/data_service.dart';
import 'package:capsule_closet_app/services/image_recog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:capsule_closet_app/services/auth_service.dart';
import '../widgets/delete_icon_button.dart';
import '../widgets/image_selection_drawer_content.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';

class UploadToClosetPage extends StatefulWidget {
  const UploadToClosetPage({super.key});
  @override
  State<UploadToClosetPage> createState() => _UploadToClosetPageState();
}

class _UploadToClosetPageState extends State<UploadToClosetPage> {
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? capturedImage = await _picker.pickImage(source: ImageSource.camera);
    if (capturedImage != null) {
      setState(() {
        _selectedImages.add(capturedImage);
      });
    }
  }

  void _showAllImagesDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return ImageSelectionDrawerContent(
              images: _selectedImages,
              scrollController: scrollController,
              onRemove: (index) {
                setState(() {
                  _selectedImages.removeAt(index);
                });
              },
              onDone: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  Future<void> _uploadItem() async {
    if (_selectedImages.isEmpty || _isUploading) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one image to upload')),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final imageRecognitionService = ImageRecognitionService();
    final dataService = Provider.of<DataService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?['id']?.toString();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to upload items.')),
      );
      setState(() {
        _isUploading = false;
      });
      return;
    }

    int successCount = 0;
    int failureCount = 0;

    for (final image in _selectedImages) {
      try {
        final recognizedItem = await imageRecognitionService.recognizeImage(image);
        if (recognizedItem != null) {
          final uploadedItem = await dataService.uploadClothingItem(
            imageFile: image,
            recognizedData: recognizedItem,
            userId: userId,
          );
          if (uploadedItem != null) {
            successCount++;
          } else {
            failureCount++;
          }
        } else {
          failureCount++;
        }
      } catch (e) {
        failureCount++;
        debugPrint('Error processing image: $e');
      }
    }

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _selectedImages.clear();
    });

    String message;
    if (successCount > 0 && failureCount == 0) {
      message = '$successCount item${successCount > 1 ? 's' : ''} uploaded to closet successfully!';
    } else if (successCount > 0 && failureCount > 0) {
      message = '$successCount item${successCount > 1 ? 's' : ''} uploaded, $failureCount failed.';
    } else {
      message = 'Upload failed. Please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _selectedImages.isEmpty
                    ? _buildEmptyState()
                    : _buildImagePreview(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 124), // Adjusted bottom padding for nav bar
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          onTap: _pickImageFromGallery,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          onTap: _takePhoto,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _isUploading ? null : _uploadItem,
                      child: GlassContainer(
                        height: 56,
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.accent.withValues(alpha: 0.3),
                        border: Border.all(color: AppColors.accent),
                        child: Center(
                          child: _isUploading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Upload to Closet',
                                      style: AppText.bodyBold.copyWith(fontSize: 18, color: Colors.white),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.glassFill.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.checkroom_rounded,
              size: 64,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your closet is waiting!',
            style: AppText.header,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Snap a photo of your clothes or pick them from your gallery to build your digital wardrobe.',
            textAlign: TextAlign.center,
            style: AppText.body,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return GlassContainer(
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.all(12),
      child: _selectedImages.length == 1
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(_selectedImages[0].path), fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildDeleteButton(0),
                  ),
                ],
              ),
            )
          : _buildGrid(),
    );
  }

  Widget _buildGrid() {
    if (_selectedImages.length <= 4) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
        ),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) => _buildGridItem(index),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => _buildGridItem(index),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _showAllImagesDrawer,
              icon: const Icon(Icons.grid_view_rounded, size: 16, color: Colors.white),
              label: Text('+${_selectedImages.length - 4} more', style: AppText.bodyBold),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildGridItem(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(_selectedImages[index].path), fit: BoxFit.cover),
          Positioned(
            top: 6,
            right: 6,
            child: _buildDeleteButton(index),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(int index) {
    return DeleteIconButton(
      onTap: () {
        setState(() {
          _selectedImages.removeAt(index);
        });
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.accent),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppText.bodyBold.copyWith(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
                        