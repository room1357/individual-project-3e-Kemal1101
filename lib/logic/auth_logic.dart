import '../models/user_model.dart';

class AuthLogic {
  // Daftar pengguna sekarang dikelola di sini.
  static final List<User> _users = [
    User(fullName: 'Kemal', username: 'kemal', password: '123', email: 'kemal@example.com'),
  ];

  /// Mencoba untuk login pengguna dengan username dan password.
  /// Mengembalikan objek [User] jika berhasil, atau `null` jika gagal.
  User? login(String username, String password) {
    try {
      // Temukan pengguna yang cocok
      final User loggedInUser = _users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
      return loggedInUser;
    } catch (e) {
      // Jika firstWhere tidak menemukan elemen, ia akan melempar StateError.
      return null;
    }
  }

  /// Mendaftarkan pengguna baru.
  /// Mengembalikan `true` jika registrasi berhasil, `false` jika username sudah ada.
  bool register(String fullName, String username, String email, String password) {
    // Periksa apakah username sudah digunakan
    if (_users.any((user) => user.username == username)) {
      return false; // Username sudah terdaftar
    }

    // Tambahkan pengguna baru ke daftar
    _users.add(User(fullName: fullName, username: username, password: password, email: email));
    return true;
  }
}
