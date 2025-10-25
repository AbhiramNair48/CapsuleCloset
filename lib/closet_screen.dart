import 'package:flutter/material.dart';

// Mock data class for clothing items
class ClothingItem {
  final String id;
  final String imagePath; // Path to the asset image
  final String type;
  final String material;
  final String color;
  final String style;
  final String description;

  ClothingItem({
    required this.id,
    required this.imagePath,
    required this.type,
    required this.material,
    required this.color,
    required this.style,
    required this.description,
  });
}

// Main screen widget
class ClosetScreen extends StatefulWidget {
  const ClosetScreen({Key? key}) : super(key: key);

  @override
  _ClosetScreenState createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  int _selectedIndex = 1; // Start with Closet tab
  List<ClothingItem> _items = [
    // Mock data for clothing items
    ClothingItem(
      id: '1',
      imagePath: 'assets/images/clothes/dress.png',
      type: 'Dress',
      material: 'Cotton',
      color: 'Blue',
      style: 'Casual',
      description: 'A comfortable summer dress.',
    ),
    ClothingItem(
      id: '2',
      imagePath: 'assets/images/clothes/shirt.png',
      type: 'Shirt',
      material: 'Linen',
      color: 'White',
      style: 'Formal',
      description: 'A crisp white linen shirt.',
    ),
    ClothingItem(
      id: '3',
      imagePath: 'assets/images/clothes/jeans.png',
      type: 'Jeans',
      material: 'Denim',
      color: 'Blue',
      style: 'Skinny',
      description: 'Dark wash skinny jeans.',
    ),
    ClothingItem(
      id: '4',
      imagePath: 'assets/images/clothes/blazer.png',
      type: 'Blazer',
      material: 'Wool',
      color: 'Black',
      style: 'Classic',
      description: 'A versatile black blazer.',
    ),
    ClothingItem(
      id: '5',
      imagePath: 'assets/images/clothes/skirt.png',
      type: 'Skirt',
      material: 'Silk',
      color: 'Red',
      style: 'Pencil',
      description: 'A silk pencil skirt.',
    ),
    ClothingItem(
      id: '6',
      imagePath: 'assets/images/clothes/sweater.png',
      type: 'Sweater',
      material: 'Cashmere',
      color: 'Gray',
      style: 'Oversized',
      description: 'A cozy gray cashmere sweater.',
    ),
    ClothingItem(
      id: '7',
      imagePath: 'assets/images/clothes/jacket.png',
      type: 'Jacket',
      material: 'Leather',
      color: 'Brown',
      style: 'Biker',
      description: 'A brown leather biker jacket.',
    ),
    ClothingItem(
      id: '8',
      imagePath: 'assets/images/clothes/trousers.png',
      type: 'Trousers',
      material: 'Chino',
      color: 'Khaki',
      style: 'Straight',
      description: 'Khaki straight-leg trousers.',
    ),
  ];

  // Handles bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Handle navigation based on the selected tab
    switch (index) {
      case 0: // Home
        _showUnderDevelopmentDialog('Home');
        break;
      case 2: // Add
        _showAddClothingDialog();
        break;
      case 3: // Friends
        _showUnderDevelopmentDialog('Friends');
        break;
      case 4: // Settings
        _showSettingsDialog();
        break;
    }
  }

  void _showUnderDevelopmentDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: Text('This feature will be implemented soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddClothingDialog() {
    _showUnderDevelopmentDialog('Add New Item');
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to profile screen
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications_outlined),
                title: Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to notifications screen
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(context, '/'); // Return to login
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show the apparel info overlay
  void _showApparelInfo(ClothingItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to expand beyond screen height
      backgroundColor: Colors.transparent, // Transparent background for overlay effect
      builder: (BuildContext context) {
        return ApparelInfoOverlay(
          item: item,
          onClose: () => Navigator.of(context).pop(), // Close the modal
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply the pink background color to the entire screen
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        // Remove default AppBar background color to let the pink background show through
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        centerTitle: true, // Center the title
        title: Text(
          'Your Digital Closet',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Ensure title text is readable on pink
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          // Create a 2-column grid
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8, // Adjust aspect ratio as needed
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return ClothingItemCard(
              item: _items[index],
              onTap: () => _showApparelInfo(_items[index]), // Show overlay on 3-dot tap
            );
          },
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures icons stay fixed size
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom), // Represents closet/hanger
            label: 'Closet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Widget for each clothing item card
class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onTap; // Callback for the 3-dot menu

  const ClothingItemCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background for the card
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Subtle shadow
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2), // Shadow offset
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image container
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.cover, // Fill the container while maintaining aspect ratio
              width: double.infinity, // Take full width of the card
              height: double.infinity, // Take full height of the card
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image fails to load
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported, size: 50),
                );
              },
            ),
          ),
          // 3-dot menu button in the top-right corner
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black54),
              onPressed: onTap, // Trigger the overlay
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for the apparel info overlay panel
class ApparelInfoOverlay extends StatefulWidget {
  final ClothingItem item;
  final VoidCallback onClose;

  const ApparelInfoOverlay({
    Key? key,
    required this.item,
    required this.onClose,
  }) : super(key: key);

  @override
  _ApparelInfoOverlayState createState() => _ApparelInfoOverlayState();
}

class _ApparelInfoOverlayState extends State<ApparelInfoOverlay> {
  late TextEditingController _typeController;
  late TextEditingController _materialController;
  late TextEditingController _colorController;
  late TextEditingController _styleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing item data
    _typeController = TextEditingController(text: widget.item.type);
    _materialController = TextEditingController(text: widget.item.material);
    _colorController = TextEditingController(text: widget.item.color);
    _styleController = TextEditingController(text: widget.item.style);
    _descriptionController = TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _typeController.dispose();
    _materialController.dispose();
    _colorController.dispose();
    _styleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      // Use a white container for the panel
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      padding: EdgeInsets.all(24.0),
      margin: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom, // Account for keyboard if needed
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8, // Start at 80% height
        minChildSize: 0.4,     // Minimum height when dragged down
        maxChildSize: 0.9,     // Maximum height when dragged up
        expand: false,         // Don't start fully expanded
        builder: (BuildContext context, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Apparel Information',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: widget.onClose, // Close the modal
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Clothing Type Field
                _buildTextField('Clothing Type', _typeController),
                SizedBox(height: 16),
                // Material Field
                _buildTextField('Material', _materialController),
                SizedBox(height: 16),
                // Color Field
                _buildTextField('Color', _colorController),
                SizedBox(height: 16),
                // Style Field
                _buildTextField('Style', _styleController),
                SizedBox(height: 16),
                // Description Field
                _buildTextField('Description', _descriptionController, maxLines: 4),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper function to build a text field with label
  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }
}