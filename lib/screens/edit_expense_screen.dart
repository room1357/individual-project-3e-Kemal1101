import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'expense_screen.dart'; // Untuk mengakses kelas Expense
import 'add_expense_screen.dart'; // Untuk mengakses kelas Category

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({
    super.key,
    required this.expense,
  });

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late int? _selectedCategoryId;
  late DateTime? _selectedDate;

  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isCategoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    // Isi form dengan data yang ada dari widget.expense
    _titleController = TextEditingController(text: widget.expense.judul);
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(0));
    _selectedCategoryId = widget.expense.categoryId;
    _selectedDate = widget.expense.date;
  }
  
  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.100.138/expenseapp/get_categories.php'));
      if (response.statusCode == 200) {
        final List<dynamic> categoryJson = json.decode(response.body);
        setState(() {
          _categories = categoryJson.map((json) => Category.fromJson(json)).toList();
          _isCategoriesLoading = false;
        });
      } else {
        throw Exception('Gagal memuat kategori');
      }
    } catch (e) {
      setState(() {
        _isCategoriesLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memuat kategori: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final uri = Uri.parse('http://192.168.100.138/expenseapp/edit_expense.php');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'expense_id': widget.expense.expenseId, // Kirim ID pengeluaran yang akan diubah
            'category_id': _selectedCategoryId,
            'judul': _titleController.text,
            'amount': double.tryParse(_amountController.text.replaceAll('.', '')),
            'description': _descriptionController.text,
            'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          }),
        );

        final result = json.decode(response.body);
        if (response.statusCode == 200 && result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perubahan berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Kirim sinyal refresh
        } else {
          throw Exception(result['message'] ?? 'Gagal menyimpan perubahan');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
    void _deleteExpense() async {
    // Tampilkan dialog konfirmasi
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus pengeluaran ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final uri = Uri.parse('http://192.168.100.138/expenseapp/delete_expense.php');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'expense_id': widget.expense.expenseId}),
        );

        final result = json.decode(response.body);
        if (response.statusCode == 200 && result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengeluaran berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
          // Kembali ke layar utama dan kirim sinyal refresh
          Navigator.of(context).pop(true);
        } else {
          throw Exception(result['message'] ?? 'Gagal menghapus pengeluaran');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengeluaran'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteExpense,
            tooltip: 'Hapus Pengeluaran',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form fields (sama seperti AddExpenseScreen, tapi sudah terisi)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Jumlah tidak boleh kosong';
                  if (double.tryParse(value.replaceAll('.', '')) == null) return 'Angka tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _isCategoriesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((Category category) {
                        return DropdownMenuItem<int>(value: category.id, child: Text(category.name));
                      }).toList(),
                      onChanged: (newValue) => setState(() => _selectedCategoryId = newValue),
                      validator: (value) => value == null ? 'Pilih kategori' : null,
                    ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _pickDate,
                  ),
                ),
                controller: TextEditingController(
                  text: _selectedDate == null
                      ? ''
                      : DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate!),
                ),
                onTap: _pickDate,
                 validator: (value) {
                  if (_selectedDate == null) {
                    return 'Tanggal harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('SIMPAN PERUBAHAN'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
