class UserProfile {
  final String name;
  final String gender;
  final String favoriteStyle;

  const UserProfile({
    this.name = '',
    this.gender = '',
    this.favoriteStyle = '',
  });

  UserProfile copyWith({
    String? name,
    String? gender,
    String? favoriteStyle,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      favoriteStyle: favoriteStyle ?? this.favoriteStyle,
    );
  }

  // Convert profile to a readable string for the AI
  String toAIContextString() {
    final buffer = StringBuffer();
    if (name.isNotEmpty) buffer.writeln('Name: $name');
    if (gender.isNotEmpty) buffer.writeln('Gender: $gender');
    if (favoriteStyle.isNotEmpty) buffer.writeln('Favorite Style: $favoriteStyle');
    
    if (buffer.isEmpty) {
      return 'No specific user profile information provided.';
    }
    return buffer.toString();
  }
}
