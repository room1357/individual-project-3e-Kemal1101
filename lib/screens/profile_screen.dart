import 'package:flutter/material.dart';
import '/models/user_model.dart';
class ProfileScreen extends StatelessWidget {
  // Tambahkan properti untuk menerima data user dan fungsi logout
  final User user;
  final VoidCallback onLogout;

  // Ubah constructor untuk menerima user dan onLogout
  const ProfileScreen({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            // Tampilkan data dari objek user
            Text(user.fullName, style: const TextStyle(fontSize: 24)),
            Text(user.email, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onLogout, // Panggil fungsi onLogout
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}