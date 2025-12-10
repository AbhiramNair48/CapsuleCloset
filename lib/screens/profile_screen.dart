import 'package:capsule_closet_app/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/data_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _styleController;

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<DataService>().userProfile;
    _nameController = TextEditingController(text: userProfile.name);
    _genderController = TextEditingController(text: userProfile.gender);
    _styleController = TextEditingController(text: userProfile.favoriteStyle);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newProfile = UserProfile(
        name: _nameController.text,
        gender: _genderController.text,
        favoriteStyle: _styleController.text,
      );

      context.read<DataService>().updateUserProfile(newProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tell us about yourself so your AI Stylist can give better recommendations.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _buildTextField('Name', _nameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField('Gender', _genderController, Icons.wc),
              const SizedBox(height: 16),
              _buildTextField(
                  'Favorite Style (e.g., Casual, Chic, Streetwear)',
                  _styleController,
                  Icons.style),
              const SizedBox(height: 24),
              Consumer<ThemeService>(
                builder: (context, themeService, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: themeService.isDarkMode,
                    onChanged: (value) {
                      themeService.toggleTheme();
                    },
                    secondary: Icon(themeService.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
