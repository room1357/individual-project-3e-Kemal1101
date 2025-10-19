import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthLogic {
  List<User> _users = [];

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://172.16.1.125/expenseapp/get_users.php'));

      if (response.statusCode == 200) {
        final List<dynamic> userJson = json.decode(response.body);
        _users = userJson.map((json) => User.fromJson(json)).toList();
        print(_users);
      } else {
        // Handle server error
        throw Exception('Failed to load users from server');
      }
    } catch (e) {
      // Handle network or other errors
      print(e);
      _users = []; // Reset users list on error
    }
  }

  /// Mencoba untuk login pengguna dengan username dan password.
  /// Mengembalikan objek [User] jika berhasil, atau `null` jika gagal.
  Future<User?> login(String username, String password) async {
    await _fetchUsers(); // Selalu fetch data terbaru
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
  Future<bool> register(String fullName, String username, String email, String password) async {
    // Fetch current users to validate username uniqueness first
    await _fetchUsers();
    if (_users.any((user) => user.username == username)) {
      return false; // Username already exists
    }

    try {
      final uri = Uri.parse('http://172.16.1.125/expenseapp/register_users.php');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fullname': fullName,
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Assume server returns JSON { "success": true } or plain 'success'
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map && decoded['success'] == true) {
            return true;
          }
        } catch (_) {
          // Not JSON, check plain text
          final body = response.body.toLowerCase();
          if (body.contains('success') || body.contains('ok')) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }
}
