import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/user_model.dart'; // Impor User model
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

// --- MODEL DATA (Diperbarui untuk cocok dengan JSON dari DB) ---
class Expense {
  final int expenseId;
  final int userId;
  final int categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String judul;
  final double amount;
  final String description;
  final DateTime date;

  Expense({
    required this.expenseId,
    required this.userId,
    required this.categoryId,
    required this.judul,
    required this.categoryName,
    this.categoryIcon,
    required this.amount,
    required this.description,
    required this.date,
  });

  // Getter untuk kompatibilitas dengan UI yang ada (menggunakan 'title')
  String get title => description;
  // Getter untuk kompatibilitas dengan UI yang ada (menggunakan 'category')
  String get category => categoryName;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expense_id'] as int,
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int,
      judul: json['judul'] as String,
      categoryName: json['category_name'] as String,
      categoryIcon: json['category_icon'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date']),
    );
  }

  // Helper untuk format mata uang
  String get formattedAmount {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  // Helper untuk format tanggal
  String get formattedDate {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }
}

// --- LOGIC MANAGER (Tidak digunakan lagi, data diambil dari API) ---
class ExpenseManager {
  static List<String> categories = [
    'Makanan',
    'Transportasi',
    'Hiburan',
    'Kebutuhan',
    'Pendidikan',
    'Utilitas',
  ];
}


// --- UI SCREEN (Versi Advanced dengan data dari Database) ---
class ExpenseScreen extends StatefulWidget {
  final User user; // Terima user yang sedang login
  const ExpenseScreen({super.key, required this.user});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Expense> _allExpenses = [];
  List<Expense> _filteredExpenses = [];
  String _selectedCategory = 'Semua';
  DateTime? _selectedMonth;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('http://localhost/expenseapp/get_expense.php?user_id=${widget.user.userId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> expenseJson = json.decode(response.body);
        setState(() {
          _allExpenses = expenseJson.map((json) => Expense.fromJson(json)).toList();
          // Data sudah diurutkan dari server (ORDER BY date DESC)
          _filterExpenses();
        });
      } else {
        throw Exception('Gagal memuat data dari server: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExpenses() {
    setState(() {
      _filteredExpenses = _allExpenses.where((expense) {
        final search = _searchController.text.toLowerCase();
        bool matchesSearch = search.isEmpty ||
            expense.title.toLowerCase().contains(search) ||
            expense.description.toLowerCase().contains(search);

        bool matchesCategory = _selectedCategory == 'Semua' ||
            expense.categoryName == _selectedCategory;
        
        // Logika filter bulan
        bool matchesMonth = _selectedMonth == null ||
            (expense.date.year == _selectedMonth!.year && expense.date.month == _selectedMonth!.month);

        return matchesSearch && matchesCategory && matchesMonth;
      }).toList();
    });
  }

  // Fungsi untuk navigasi ke halaman tambah dan refresh data setelah kembali
  void _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpenseScreen(user: widget.user)),
    );

    // Jika `result` adalah true, berarti ada data baru, panggil API lagi
    if (result == true) {
      _fetchExpenses();
    }
  }

  // Fungsi untuk navigasi ke halaman edit dan refresh data setelah kembali
  void _navigateToEdit(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expense,
        ),
      ),
    );

    // Jika `result` adalah true, berarti ada perubahan, panggil API lagi
    if (result == true) {
      _fetchExpenses();
    }
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0, (sum, expense) => sum + expense.amount);
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(total);
  }

  String _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 'Rp 0';
    double average = expenses.fold(0.0, (sum, expense) => sum + expense.amount) / expenses.length;
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(average);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan': return Colors.orange;
      case 'Transportasi': return Colors.blue;
      case 'Hiburan': return Colors.purple;
      case 'Kebutuhan': return Colors.green;
      case 'Pendidikan': return Colors.indigo;
      case 'Utilitas': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan': return Icons.fastfood;
      case 'Transportasi': return Icons.directions_car;
      case 'Hiburan': return Icons.movie;
      case 'Kebutuhan': return Icons.shopping_cart;
      case 'Pendidikan': return Icons.school;
      case 'Utilitas': return Icons.power;
      default: return Icons.category;
    }
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                expense.formattedAmount,
                style: TextStyle(fontSize: 20, color: Colors.red[700], fontWeight: FontWeight.w500),
              ),
              const Divider(height: 24),
              Text(
                expense.description,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(_getCategoryIcon(expense.category), color: _getCategoryColor(expense.category), size: 18),
                  const SizedBox(width: 8),
                  Text(expense.category, style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(expense.formattedDate, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),
              // Tombol Edit
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Tutup modal
                    _navigateToEdit(expense); // Panggil fungsi navigasi edit
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('EDIT'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Daftar kategori dinamis dari data yang ada + 'Semua'
    final categories = ['Semua', ..._allExpenses.map((e) => e.categoryName).toSet().toList()];
    
    // Daftar bulan dinamis dari data yang ada
    final months = _allExpenses
        .map((e) => DateTime(e.date.year, e.date.month))
        .toSet()
        .toList();

    return Scaffold(
      // Tombol Tambah Pengeluaran
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefresh,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengeluaran...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => _filterExpenses(),
            ),
          ),

          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Filter Bulan
                Expanded(
                  child: DropdownButton<DateTime?>( // Izinkan nilai null
                    isExpanded: true,
                    value: _selectedMonth,
                    hint: const Text('Semua Bulan'),
                    onChanged: (DateTime? newValue) {
                      setState(() {
                        _selectedMonth = newValue;
                        _filterExpenses();
                      });
                    },
                    items: [
                      // Tambahkan item "Semua Bulan" secara manual
                      const DropdownMenuItem<DateTime?>(
                        value: null,
                        child: Text('Semua Bulan'),
                      ),
                      // Tambahkan sisa bulan dari data
                      ...months.map<DropdownMenuItem<DateTime?>>((DateTime month) {
                        return DropdownMenuItem<DateTime?>(
                          value: month,
                          child: Text(DateFormat('MMMM yyyy', 'id_ID').format(month)),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Filter Kategori
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                        _filterExpenses();
                      });
                    },
                    items: categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Statistics summary
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Total', _calculateTotal(_filteredExpenses)),
                  _buildStatCard('Jumlah', '${_filteredExpenses.length} item'),
                  _buildStatCard('Rata-rata', _calculateAverage(_filteredExpenses)),
                ],
              ),
            ),
          ),

          // Expense list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, textAlign: TextAlign.center))
                    : _filteredExpenses.isEmpty
                        ? const Center(child: Text('Tidak ada pengeluaran ditemukan'))
                        : RefreshIndicator(
                            onRefresh: _fetchExpenses,
                            child: ListView.builder(
                              itemCount: _filteredExpenses.length,
                              itemBuilder: (context, index) {
                                final expense = _filteredExpenses[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getCategoryColor(expense.categoryName),
                                      child: Icon(_getCategoryIcon(expense.categoryName), color: Colors.white, size: 20),
                                    ),
                                    title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text('${expense.categoryName} • ${expense.formattedDate}'),
                                    trailing: Text(
                                      expense.formattedAmount,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                    onTap: () => _showExpenseDetails(context, expense),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}