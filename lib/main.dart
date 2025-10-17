import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'widgets/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _currentUser;

  void _login(User user) {
    setState(() {
      _currentUser = user;
    });
  }

  void _logout() {
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _currentUser == null
          ? LoginScreen(onLogin: _login)
          : MainScaffold(user: _currentUser!, onLogout: _logout),
    );
  }
}
