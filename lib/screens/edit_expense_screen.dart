import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_screen.dart'; // Untuk mengakses kelas Expense

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  final int expenseIndex;

  const EditExpenseScreen({
    super.key,
    required this.expense,
    required this.expenseIndex,
  });

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late String? _selectedCategory;
  late DateTime? _selectedDate;

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
  void initState() {
    super.initState();
    // Isi form dengan data yang ada
    _titleController = TextEditingController(text: widget.expense.title);
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(0));
    _selectedCategory = widget.expense.category;
    _selectedDate = widget.expense.date;
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

  void _submitChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedExpense = Expense(
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text.replaceAll('.', '')),
        category: _selectedCategory!,
        date: _selectedDate!,
      );

      // Perbarui item di daftar statis menggunakan indeks
      ExpenseManager.expenses[widget.expenseIndex] = updatedExpense;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan berhasil disimpan!'),
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
        title: const Text('Edit Pengeluaran'),
        backgroundColor: Colors.orange,
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
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Jumlah tidak boleh kosong';
                  if (double.tryParse(value.replaceAll('.', '')) == null) return 'Angka tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(value: category, child: Text(category));
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Pilih Tanggal'
                    : DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitChanges,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('SIMPAN PERUBAHAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
