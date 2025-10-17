import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_screen.dart'; // Untuk mengakses kelas Expense dan ExpenseManager

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCategory;
  DateTime? _selectedDate;

  // Kategori yang bisa dipilih
  final List<String> _categories = [
    'Makanan',
    'Transportasi',
    'Hiburan',
    'Kebutuhan',
    'Pendidikan',
    'Utilitas',
    'Lainnya'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan pemilih tanggal
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // Tidak bisa memilih tanggal di masa depan
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Fungsi untuk menyimpan data pengeluaran
  void _submitExpense() {
    // Jalankan validasi form
    if (_formKey.currentState!.validate()) {
      final newExpense = Expense(
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text.replaceAll('.', '')), // Hapus titik jika ada
        category: _selectedCategory!,
        date: _selectedDate!,
      );

      // Tambahkan ke daftar statis di ExpenseManager
      ExpenseManager.expenses.add(newExpense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengeluaran berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke layar sebelumnya dan kirim sinyal untuk refresh
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengeluaran'),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Judul
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Jumlah
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value.replaceAll('.', '')) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),

              // Pemilih Tanggal
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate == null
                      ? 'Pilih Tanggal'
                      : DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _pickDate,
              ),
              // Validator manual untuk tanggal
              if (_formKey.currentState?.validate() == false && _selectedDate == null)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                  child: Text(
                    'Tanggal harus dipilih',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _submitExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('SIMPAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
