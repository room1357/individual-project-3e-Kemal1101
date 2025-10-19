class User {
  final int userId;
  final String fullName;
  final String email;
  final String username;
  final String password;
  final String tanggalDibuat;

  User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    required this.tanggalDibuat,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: int.parse(json['user_id']),
      fullName: json['fullname'],
      email: json['email'],
      username: json['username'],
      password: json['password'],
      tanggalDibuat: json['tanggal_dibuat'],
    );
  }
}

