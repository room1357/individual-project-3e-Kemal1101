import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_expense_screen.dart'; // Impor layar tambah pengeluaran
import 'edit_expense_screen.dart'; // Impor layar edit

// --- MODEL DATA (Tidak berubah) ---
class Expense {
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

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

// --- LOGIC MANAGER (Tidak berubah) ---
class ExpenseManager {
  // Data contoh
  static List<Expense> expenses = [
  ];

  // Fungsi-fungsi lain tidak diperlukan untuk UI baru ini, tapi bisa disimpan
}


// --- UI SCREEN (Versi Advanced) ---
class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final List<Expense> _allExpenses = ExpenseManager.expenses;
  List<Expense> _filteredExpenses = [];
  String _selectedCategory = 'Semua';
  DateTime? _selectedMonth; // State untuk filter bulan
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Urutkan data dari yang terbaru
    _allExpenses.sort((a, b) => b.date.compareTo(a.date));
    _filteredExpenses = _allExpenses;
    _filterExpenses(); // Panggil filter saat inisialisasi
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
            expense.category == _selectedCategory;
        
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
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );

    // Jika `result` adalah true, berarti ada data baru yang ditambahkan
    if (result == true) {
      setState(() {
        // Urutkan ulang daftar utama karena ada item baru
        _allExpenses.sort((a, b) => b.date.compareTo(a.date));
        // Terapkan filter lagi untuk memperbarui UI
        _filterExpenses();
      });
    }
  }

  // Fungsi untuk navigasi ke halaman edit dan refresh data setelah kembali
  void _navigateToEdit(Expense expense) async {
    // Dapatkan indeks item yang akan diedit dari daftar utama
    final int expenseIndex = _allExpenses.indexOf(expense);
    if (expenseIndex == -1) return; // Pengaman jika item tidak ditemukan

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expense,
          expenseIndex: expenseIndex,
        ),
      ),
    );

    // Jika `result` adalah true, berarti ada perubahan yang disimpan
    if (result == true) {
      setState(() {
        // Urutkan ulang dan filter lagi untuk memperbarui UI
        _allExpenses.sort((a, b) => b.date.compareTo(a.date));
        _filterExpenses();
      });
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
    final categories = ['Semua', ..._allExpenses.map((e) => e.category).toSet().toList()];
    
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
            child: _filteredExpenses.isEmpty
                ? const Center(child: Text('Tidak ada pengeluaran ditemukan'))
                : ListView.builder(
                    itemCount: _filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = _filteredExpenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(expense.category),
                            child: Icon(_getCategoryIcon(expense.category), color: Colors.white, size: 20),
                          ),
                          title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${expense.category} • ${expense.formattedDate}'),
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
        ],
      ),
    );
  }
}