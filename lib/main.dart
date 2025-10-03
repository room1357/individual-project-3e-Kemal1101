import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/expense_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
      // 2. Hapus 'routes' dan gunakan 'onGenerateRoute' untuk rute yang butuh parameter
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            // Ambil argumen yang dikirim saat navigasi
            final user = settings.arguments as User;
            return MaterialPageRoute(
              builder: (context) => HomeScreen(user: user),
            );
          case '/profile':
            // Argumen juga bisa dikirim ke profile jika diperlukan
            final user = settings.arguments as User;
            return MaterialPageRoute(
              builder: (context) => ProfileScreen(user: user),
            );
          case '/settings':
            return MaterialPageRoute(builder: (context) => const SettingsScreen());
          case '/about':
            return MaterialPageRoute(builder: (context) => const AboutScreen());
          case '/expense':
            return MaterialPageRoute(builder: (context) => const ExpenseScreen());
          case '/logout':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          default:
            // Jika rute tidak ditemukan, bisa arahkan ke halaman error atau default
            return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
      },
    );
  }
}
