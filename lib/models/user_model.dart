class User {
  final int id;
  final String fullName;
  final String email;
  final String username;

  static User? currentUser;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      fullName: json['fullname'],
      email: json['email'],
      username: json['username'],
    );
  }
}

