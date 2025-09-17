class User {
  final String id;
  final String name;
  final String profilePicture;
  final String? email;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.profilePicture,
    this.email,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_picture': profilePicture,
      'email': email,
      'phone': phone,
    };
  }
}



