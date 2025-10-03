import 'package:flutter/material.dart';
import '/models/user_model.dart';
class ProfileScreen extends StatelessWidget {
  // Tambahkan properti untuk menerima data user
  final User user;

  // Ubah constructor untuk menerima user
  const ProfileScreen({super.key, required this.user});

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
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/logout');
              },
              child: const Text('Logout'), // Ganti teks tombol
            ),
          ],
        ),
      ),
    );
  }
}