class UserProfile {
  final String name;
  final String gender;
  final String favoriteStyle;
  final bool isDailyNotificationEnabled;
  final String? notificationTime; // Format: "HH:mm"
  final String? notificationOccasion;

  const UserProfile({
    this.name = '',
    this.gender = '',
    this.favoriteStyle = '',
    this.isDailyNotificationEnabled = false,
    this.notificationTime,
    this.notificationOccasion,
  });

  UserProfile copyWith({
    String? name,
    String? gender,
    String? favoriteStyle,
    bool? isDailyNotificationEnabled,
    String? notificationTime,
    String? notificationOccasion,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      favoriteStyle: favoriteStyle ?? this.favoriteStyle,
      isDailyNotificationEnabled: isDailyNotificationEnabled ?? this.isDailyNotificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationOccasion: notificationOccasion ?? this.notificationOccasion,
    );
  }

  // Convert profile to a readable string for the AI
  String toAIContextString() {
    final buffer = StringBuffer();
    if (name.isNotEmpty) buffer.writeln('Name: $name');
    if (gender.isNotEmpty) buffer.writeln('Gender: $gender');
    if (favoriteStyle.isNotEmpty) buffer.writeln('Favorite Style: $favoriteStyle');
    if (notificationOccasion != null && notificationOccasion!.isNotEmpty) {
      buffer.writeln('Daily Outfit Occasion: $notificationOccasion');
    }
    
    if (buffer.isEmpty) {
      return 'No specific user profile information provided.';
    }
    return buffer.toString();
  }
}