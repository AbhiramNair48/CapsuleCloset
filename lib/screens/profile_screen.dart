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
  late TextEditingController _bodyTypeController;
  late TextEditingController _occasionsController;
  late TextEditingController _goalsController;

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<DataService>().userProfile;
    _nameController = TextEditingController(text: userProfile.name);
    _genderController = TextEditingController(text: userProfile.gender);
    _styleController = TextEditingController(text: userProfile.favoriteStyle);
    _bodyTypeController = TextEditingController(text: userProfile.bodyType);
    _occasionsController = TextEditingController(text: userProfile.typicalOccasions);
    _goalsController = TextEditingController(text: userProfile.fashionGoals);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _styleController.dispose();
    _bodyTypeController.dispose();
    _occasionsController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newProfile = UserProfile(
        name: _nameController.text,
        gender: _genderController.text,
        favoriteStyle: _styleController.text,
        bodyType: _bodyTypeController.text,
        typicalOccasions: _occasionsController.text,
        fashionGoals: _goalsController.text,
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
              _buildTextField('Favorite Style (e.g., Casual, Chic, Streetwear)', _styleController, Icons.style),
              const SizedBox(height: 16),
              _buildTextField('Body Type', _bodyTypeController, Icons.accessibility_new),
              const SizedBox(height: 16),
              _buildTextField('Typical Occasions (e.g., Office, Parties, Gym)', _occasionsController, Icons.event),
              const SizedBox(height: 16),
              _buildTextField('Fashion Goals', _goalsController, Icons.flag_outlined, maxLines: 3),
              const SizedBox(height: 32),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
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
