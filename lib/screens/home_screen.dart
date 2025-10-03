import 'package:flutter/material.dart';
import 'expense_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  // Ubah constructor untuk menerima user
  const HomeScreen({super.key, required this.user});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar widget di sini
    _widgetOptions = <Widget>[
      const ProductGrid(),
      const ExpenseScreen(),
      ProfileScreen(user: widget.user), // Teruskan user ke ProfileScreen
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Expenses';
      case 2:
        return 'Profile';
      case 3:
        return 'Settings';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              // Logika untuk logout
              Navigator.pushReplacementNamed(context, '/logout');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Agar semua item terlihat
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 0 || _selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            // Aksi untuk menambah produk baru
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menambah produk baru...')),
            );
          } else if (_selectedIndex == 1) {
            // Aksi untuk menambah pengeluaran baru
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menambah pengeluaran baru...')),
            );
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      );
    }
    return null; // Tidak menampilkan FAB di halaman lain
  }
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3 / 4,
        ),
        itemCount: 10, // Jumlah produk
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${(index + 1) * 50000}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}