class UserProfile {
  final String name;
  final String gender;
  final String favoriteStyle;
  final String bodyType;
  final String typicalOccasions;
  final String fashionGoals;

  const UserProfile({
    this.name = '',
    this.gender = '',
    this.favoriteStyle = '',
    this.bodyType = '',
    this.typicalOccasions = '',
    this.fashionGoals = '',
  });

  UserProfile copyWith({
    String? name,
    String? gender,
    String? favoriteStyle,
    String? bodyType,
    String? typicalOccasions,
    String? fashionGoals,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      favoriteStyle: favoriteStyle ?? this.favoriteStyle,
      bodyType: bodyType ?? this.bodyType,
      typicalOccasions: typicalOccasions ?? this.typicalOccasions,
      fashionGoals: fashionGoals ?? this.fashionGoals,
    );
  }

  // Convert profile to a readable string for the AI
  String toAIContextString() {
    final buffer = StringBuffer();
    if (name.isNotEmpty) buffer.writeln('Name: $name');
    if (gender.isNotEmpty) buffer.writeln('Gender: $gender');
    if (favoriteStyle.isNotEmpty) buffer.writeln('Favorite Style: $favoriteStyle');
    if (bodyType.isNotEmpty) buffer.writeln('Body Type: $bodyType');
    if (typicalOccasions.isNotEmpty) buffer.writeln('Typical Occasions: $typicalOccasions');
    if (fashionGoals.isNotEmpty) buffer.writeln('Fashion Goals: $fashionGoals');
    
    if (buffer.isEmpty) {
      return 'No specific user profile information provided.';
    }
    return buffer.toString();
  }
}
