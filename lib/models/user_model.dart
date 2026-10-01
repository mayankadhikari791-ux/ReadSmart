class User {
  final String id;
  final String name;
  final String email;
  final String readingLevel;
  final String avatarInitials;
  final String memberSince;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.readingLevel = 'Advanced Reader',
    this.avatarInitials = 'M',
    this.memberSince = 'Reading since Jan 2024',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'readingLevel': readingLevel,
      'avatarInitials': avatarInitials,
      'memberSince': memberSince,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      readingLevel: json['readingLevel'] as String? ?? 'Advanced Reader',
      avatarInitials: json['avatarInitials'] as String? ?? 'M',
      memberSince: json['memberSince'] as String? ?? 'Reading since Jan 2024',
    );
  }
}
