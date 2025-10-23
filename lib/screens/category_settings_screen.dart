import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/category_model.dart'; // Menggunakan model Category terpisah

class CategorySettingsScreen extends StatefulWidget {
  const CategorySettingsScreen({super.key});

  @override
  _CategorySettingsScreenState createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse('http://192.168.100.138/expenseapp/get_categories.php'));
      if (response.statusCode == 200) {
        final List<dynamic> categoryJson = json.decode(response.body);
        setState(() {
          _categories = categoryJson.map((json) => Category.fromJson(json)).toList();
        });
      } else {
        throw Exception('Gagal memuat kategori dari server');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCategory(String name, String icon) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.138/expenseapp/add_category.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'icon': icon}),
      );
      final result = json.decode(response.body);
      if (response.statusCode == 201 && result['status'] == 'success') {
        _fetchCategories(); // Muat ulang daftar kategori
        Navigator.pop(context); // Tutup dialog
      } else {
        throw Exception(result['message'] ?? 'Gagal menambah kategori');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _editCategory(int id, String newName, String newIcon) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.138/expenseapp/edit_category.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category_id': id, 'name': newName, 'icon': newIcon}),
      );
      final result = json.decode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        _fetchCategories(); // Muat ulang
        Navigator.pop(context); // Tutup dialog
      } else {
        throw Exception(result['message'] ?? 'Gagal mengedit kategori');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteCategory(int id) async {
    // Tampilkan dialog konfirmasi
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus kategori ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.100.138/expenseapp/delete_category.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'category_id': id}),
        );
        final result = json.decode(response.body);
        if (response.statusCode == 200 && result['status'] == 'success') {
          _fetchCategories(); // Muat ulang
        } else {
          throw Exception(result['message'] ?? 'Gagal menghapus kategori');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    _nameController.clear();
    _iconController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Nama Kategori'),
                autofocus: true,
              ),
              TextField(
                controller: _iconController,
                decoration: const InputDecoration(hintText: 'Ikon (Emoji)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _iconController.text.isNotEmpty) {
                  _addCategory(_nameController.text, _iconController.text);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    _nameController.text = category.name;
    _iconController.text = category.icon ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Nama Kategori'),
                autofocus: true,
              ),
              TextField(
                controller: _iconController,
                decoration: const InputDecoration(hintText: 'Ikon (Emoji)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _iconController.text.isNotEmpty) {
                  _editCategory(category.id, _nameController.text, _iconController.text);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchCategories,
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return ListTile(
                        leading: Text(
                          category.icon ?? '❓',
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(category.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showEditCategoryDialog(category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(category.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
