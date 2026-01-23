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
  
  bool _isDailyNotificationEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  String _notificationOccasion = 'Casual';
  
  final List<String> _occasions = ['Casual', 'Work', 'Party', 'Date', 'Gym', 'School'];

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<DataService>().userProfile;
    _nameController = TextEditingController(text: userProfile.name);
    _genderController = TextEditingController(text: userProfile.gender);
    _styleController = TextEditingController(text: userProfile.favoriteStyle);
    
    _isDailyNotificationEnabled = userProfile.isDailyNotificationEnabled;
    if (userProfile.notificationTime != null) {
      final parts = userProfile.notificationTime!.split(':');
      if (parts.length == 2) {
        _notificationTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    if (userProfile.notificationOccasion != null && _occasions.contains(userProfile.notificationOccasion)) {
      _notificationOccasion = userProfile.notificationOccasion!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final newProfile = UserProfile(
        name: _nameController.text,
        gender: _genderController.text,
        favoriteStyle: _styleController.text,
        isDailyNotificationEnabled: _isDailyNotificationEnabled,
        notificationTime: '${_notificationTime.hour}:${_notificationTime.minute.toString().padLeft(2, '0')}',
        notificationOccasion: _notificationOccasion,
      );

      context.read<DataService>().updateUserProfile(newProfile);
      
      // Save notification settings explicitly to handle scheduling
      await context.read<DataService>().saveNotificationSettings(
        _isDailyNotificationEnabled,
        '${_notificationTime.hour}:${_notificationTime.minute.toString().padLeft(2, '0')}',
        _notificationOccasion,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile and settings saved successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
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
              
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Daily Outfit Notification',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SwitchListTile(
                title: const Text('Enable Daily Notifications'),
                subtitle: const Text('Get an outfit suggestion every day'),
                value: _isDailyNotificationEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isDailyNotificationEnabled = value;
                  });
                },
              ),
              if (_isDailyNotificationEnabled) ...[
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Notification Time'),
                  trailing: Text(_notificationTime.format(context)),
                  onTap: () => _selectTime(context),
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Occasion'),
                  trailing: DropdownButton<String>(
                    value: _notificationOccasion,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _notificationOccasion = newValue;
                        });
                      }
                    },
                    items: _occasions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const Divider(),
              const SizedBox(height: 8),

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
