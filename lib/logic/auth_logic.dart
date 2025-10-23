import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthLogic {
  final String baseUrl = 'http://192.168.100.138/expenseapp';

  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final user = User.fromJson(data['user']);
          User.currentUser = user;
          return user;
        } else {
          // Cetak pesan error dari server jika ada
          if (data.containsKey('message')) {
            print('Login error from server: ${data['message']}');
          }
          return null;
        }
      } else {
        // Cetak body response untuk debugging jika status code bukan 200
        print('Failed to connect to server. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Gagal terhubung ke server.');
      }
    } catch (e) {
      print(e);
      
      return null;
    }
  }

  Future<Map<String, dynamic>> register(String fullName, String username, String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/register_user.php');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullname': fullName, // Sesuaikan dengan field di register_user.php
          'username': username,
          'email': email,
          'password': password
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 409) {
        return {'status': 'error', 'message': 'Username atau email sudah terdaftar.'};
      } 
      else {
        print('Failed to register. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {'status': 'error', 'message': 'Gagal mendaftar. Kode: ${response.statusCode}'};
      }
    } catch (e) {
      print('Register error: $e');
      return {'status': 'error', 'message': 'Terjadi kesalahan jaringan.'};
    }
  }
}
