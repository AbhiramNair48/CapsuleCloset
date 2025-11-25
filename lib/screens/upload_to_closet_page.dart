import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadToClosetPage extends StatefulWidget {
  const UploadToClosetPage({super.key});

  @override
  State<UploadToClosetPage> createState() => _UploadToClosetPageState();
}

class _UploadToClosetPageState extends State<UploadToClosetPage> {
  final List<XFile> _selectedImages = [];

  final ImagePicker _picker = ImagePicker();

  // Function to pick multiple images from gallery
  Future<void> _pickImageFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  // Function to take a photo using camera
  Future<void> _takePhoto() async {
    final XFile? capturedImage = await _picker.pickImage(source: ImageSource.camera);
    if (capturedImage != null) {
      setState(() {
        _selectedImages.add(capturedImage);
      });
    }
  }

  // Function to show all images in a drawer
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
            // Create a local copy of the images to work with in the drawer
            List<XFile> drawerImages = List.from(_selectedImages);
            
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDrawerState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Selected Items (${drawerImages.length})',
                                                      style: Theme.of(context).textTheme.titleLarge,
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: const Text('Done'),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Expanded(
                                                  child: GridView.builder(
                                                    controller: scrollController,
                                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                                      maxCrossAxisExtent: 120,
                                                      mainAxisSpacing: 12,
                                                      crossAxisSpacing: 12,
                                                      childAspectRatio: 1,
                                                    ),
                                                    itemCount: drawerImages.length, // Show all images
                                                    itemBuilder: (context, index) {
                                                      // Make sure index is within bounds in case the list changed
                                                      if (index >= drawerImages.length) {
                                                        return Container(); // Return empty container if index out of bounds
                                                      }
                                                      
                                                      return Card(
                                                        clipBehavior: Clip.antiAlias,
                                                        child: Stack(
                                                          fit: StackFit.expand, // Ensure the stack fills the container
                                                          children: [
                                                            // The image
                                                            Image.file(
                                                              File(drawerImages[index].path),
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return const Icon(
                                                                  Icons.broken_image,
                                                                  size: 30,
                                                                  color: Colors.grey,
                                                                );
                                                              },
                                                            ),
                                                            // Top-right positioned delete button - sits directly on the image
                                                            Positioned(
                                                              top: 6,
                                                              right: 6,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  // Remove from both the local list and the main list
                                                                  setDrawerState(() {
                                                                    drawerImages.removeAt(index);
                                                                  });
                                                                  
                                                                  setState(() {
                                                                    _selectedImages.removeAt(index);
                                                                  });
                                                                },
                                                                child: Container(
                                                                  padding: const EdgeInsets.all(6),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white.withValues(alpha: 0.9),
                                                                    shape: BoxShape.circle,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors.black.withValues(alpha: 0.1),
                                                                        blurRadius: 2,
                                                                      )
                                                                    ]
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons.close,
                                                                    size: 16,
                                                                    color: Colors.redAccent,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          }
                        
                          // Stub function for uploading the items to closet
                          void _uploadItem() {
                            if (_selectedImages.isNotEmpty) {
                              // TODO: Implement actual upload functionality
                              
                              // Simulate upload success
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${_selectedImages.length} items uploaded to closet successfully!'),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              
                              // Clear the selected images after upload
                              setState(() {
                                _selectedImages.clear();
                              });
                            } else {
                              // Show error if no image selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Please select at least one image to upload'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        
                          @override
                          Widget build(BuildContext context) {
                            // Calculate screen dimensions for responsive design
                            final screenHeight = MediaQuery.of(context).size.height;
                            
                            final theme = Theme.of(context);
                        
                            return Scaffold(
                              // Background handled by theme
                              body: SafeArea(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Main Content Area
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: _selectedImages.isEmpty
                                            ? BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(32.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.pink.withValues(alpha: 0.1),
                                                    spreadRadius: 2,
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              )
                                            : null,
                                        clipBehavior: _selectedImages.isEmpty ? Clip.hardEdge : Clip.none,
                                        child: _selectedImages.isEmpty
                                            ? _buildEmptyState()
                                            : _buildImagePreview(screenHeight),
                                      ),
                                    ),
                        
                                    // Bottom Action Area
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildActionButton(
                                                  icon: Icons.photo_library_rounded,
                                                  label: 'Gallery',
                                                  onTap: _pickImageFromGallery,
                                                  color: Colors.white,
                                                  textColor: theme.colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildActionButton(
                                                  icon: Icons.camera_alt_rounded,
                                                  label: 'Camera',
                                                  onTap: _takePhoto,
                                                  color: Colors.white,
                                                  textColor: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          if (_selectedImages.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 56,
                                              child: FilledButton.icon(
                                                onPressed: _uploadItem,
                                                icon: const Icon(Icons.cloud_upload_rounded),
                                                label: const Text(
                                                  'Upload to Closet',
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                                style: FilledButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
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
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.checkroom_rounded,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Your closet is waiting!',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'Snap a photo of your clothes or pick them from your gallery to build your digital wardrobe.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            );
                          }
                        
                          Widget _buildImagePreview(double screenHeight) {
                            if (_selectedImages.length == 1) {
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      File(_selectedImages[0].path),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                        );
                                      },
                                    ),
                                    // Gradient overlay for better visibility of the delete button
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withValues(alpha: 0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 16,
                                      right: 16,
                                      child: _buildDeleteButton(0),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: _selectedImages.length <= 4
                                    ? GridView.builder(
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
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 48), // Spacer to balance the button height for centering
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
                                            child: FilledButton.tonalIcon(
                                              onPressed: _showAllImagesDrawer,
                                              icon: const Icon(Icons.grid_view_rounded, size: 16),
                                              label: Text('+${_selectedImages.length - 4} more'),
                                            ),
                                          ),
                                        ],
                                      ),
                                ),
                              );
                            }
                          }
                        
                          Widget _buildGridItem(int index) {
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(_selectedImages[index].path),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[100],
                                        child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                                      );
                                    },
                                  ),
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
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                              ),
                            );
                          }
                        
                          Widget _buildActionButton({
                            required IconData icon,
                            required String label,
                            required VoidCallback onTap,
                            required Color color,
                            required Color textColor,
                          }) {
                            return OutlinedButton(
                              onPressed: onTap,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                                backgroundColor: color,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(icon, size: 32, color: textColor),
                                  const SizedBox(height: 8),
                                  Text(
                                    label,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                        