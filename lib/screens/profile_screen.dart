import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/data_service.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';

import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  bool _isUploading = false;
  
  final List<String> _standardOccasions = ['Casual', 'Work', 'Party', 'Date', 'Gym', 'School'];
  List<String> get _currentOccasionList {
    if (!_standardOccasions.contains(_notificationOccasion) && _notificationOccasion.isNotEmpty) {
      return [..._standardOccasions, _notificationOccasion, 'Custom'];
    }
    return [..._standardOccasions, 'Custom'];
  }

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
    if (userProfile.notificationOccasion != null) {
      _notificationOccasion = userProfile.notificationOccasion!;
    }
  }

  Future<void> _handleOccasionChange(String? newValue) async {
    if (newValue == 'Custom') {
      final customController = TextEditingController();
      final String? customOccasion = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text('Enter Custom Occasion', style: AppText.header.copyWith(fontSize: 20)),
          content: GlassContainer(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withValues(alpha: 0.05),
            child: TextField(
              controller: customController,
              style: AppText.body.copyWith(color: Colors.white),
              cursorColor: AppColors.accent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: 'e.g., Wedding',
                hintStyle: TextStyle(color: Colors.white30),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, customController.text.trim()),
              child: Text('OK', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (customOccasion != null && customOccasion.isNotEmpty) {
        setState(() {
          _notificationOccasion = customOccasion;
        });
      }
    } else if (newValue != null) {
      setState(() {
        _notificationOccasion = newValue;
      });
    }
  }

  Future<void> _pickImage() async {
    final messenger = ScaffoldMessenger.of(context);
    final dataService = context.read<DataService>();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (!mounted) return;

    if (image != null) {
      setState(() => _isUploading = true);
      
      final url = await dataService.uploadProfilePicture(image);
      
      if (!mounted) return;

      setState(() => _isUploading = false);
      
      if (url != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to update profile picture')),
        );
      }
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
      final dataService = context.read<DataService>();
      final currentProfile = dataService.userProfile;
      final newProfile = UserProfile(
        name: _nameController.text,
        gender: _genderController.text,
        favoriteStyle: _styleController.text,
        profilePicUrl: currentProfile.profilePicUrl, 
        isDailyNotificationEnabled: _isDailyNotificationEnabled,
        notificationTime: '${_notificationTime.hour}:${_notificationTime.minute.toString().padLeft(2, '0')}',
        notificationOccasion: _notificationOccasion,
      );

      // Update backend (User table)
      await dataService.updateUserProfile(newProfile);
      
      // Save notification settings explicitly
      await dataService.saveNotificationSettings(
        _isDailyNotificationEnabled,
        '${_notificationTime.hour}:${_notificationTime.minute.toString().padLeft(2, '0')}',
        _notificationOccasion,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile and settings saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<DataService>().userProfile;

    return GlassScaffold(
      appBar: AppBar(
        title: Text('My Profile', style: AppText.header),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white10,
                        backgroundImage: userProfile.profilePicUrl != null
                            ? CachedNetworkImageProvider(userProfile.profilePicUrl!)
                            : null,
                        child: _isUploading
                            ? const CircularProgressIndicator(color: AppColors.accent)
                            : userProfile.profilePicUrl == null
                                ? const Icon(Icons.person, size: 60, color: Colors.white54)
                                : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: GlassContainer(
                          width: 40,
                          height: 40,
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.accent,
                          border: Border.all(color: Colors.white24),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GlassContainer(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.all(16),
                color: AppColors.glassFill.withValues(alpha: 0.05),
                child: Text(
                  'Tell us about yourself so your AI Stylist can give better recommendations.',
                  style: AppText.body.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Name', _nameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField('Gender', _genderController, Icons.wc),
              const SizedBox(height: 16),
              _buildTextField(
                  'Favorite Style (e.g., Casual, Chic)',
                  _styleController,
                  Icons.style),
              const SizedBox(height: 32),
              
              Text(
                'Daily Outfit Notification',
                style: AppText.title,
              ),
              const SizedBox(height: 16),
              
              GlassContainer(
                borderRadius: BorderRadius.circular(16),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Enable Notifications', style: AppText.bodyBold.copyWith(color: Colors.white)),
                      subtitle: Text('Get an outfit suggestion every day', style: AppText.label.copyWith(color: Colors.white54)),
                      value: _isDailyNotificationEnabled,
                      thumbColor: WidgetStateProperty.all(AppColors.accent),
                      trackColor: WidgetStateProperty.resolveWith((states) => 
                        states.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3)
                      ),
                      onChanged: (bool value) {
                        setState(() {
                          _isDailyNotificationEnabled = value;
                        });
                      },
                    ),
                    if (_isDailyNotificationEnabled) ...[
                      const Divider(color: Colors.white10, height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time, color: AppColors.accent),
                        title: Text('Time', style: AppText.body.copyWith(color: Colors.white)),
                        trailing: Text(_notificationTime.format(context), style: AppText.bodyBold.copyWith(color: AppColors.accent)),
                        onTap: () => _selectTime(context),
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      ListTile(
                        leading: const Icon(Icons.event, color: AppColors.accent),
                        title: Text('Occasion', style: AppText.body.copyWith(color: Colors.white)),
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentOccasionList.contains(_notificationOccasion) ? _notificationOccasion : 'Custom',
                            dropdownColor: const Color(0xFF2C2C2E),
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
                            style: AppText.bodyBold.copyWith(color: AppColors.accent),
                            onChanged: _handleOccasionChange,
                            items: _currentOccasionList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _saveProfile,
                child: GlassContainer(
                  height: 56,
                  borderRadius: BorderRadius.circular(28),
                  color: AppColors.accent.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                  child: Center(
                    child: Text(
                      'Save Profile',
                      style: AppText.bodyBold.copyWith(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label.copyWith(color: Colors.white70)),
        const SizedBox(height: 8),
        GlassContainer(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white.withValues(alpha: 0.05),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: AppText.body.copyWith(color: Colors.white),
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.accent),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
