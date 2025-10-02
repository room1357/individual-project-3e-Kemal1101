import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    Expense(title: 'Kopi Susu', description: 'Meeting dengan klien', amount: 25000, category: 'Makanan', date: DateTime(2025, 9, 22)),
    Expense(title: 'Nasi Goreng', description: 'Makan malam', amount: 35000, category: 'Makanan', date: DateTime(2025, 9, 22)),
    Expense(title: 'Bensin Motor', description: 'Isi full tank', amount: 50000, category: 'Transportasi', date: DateTime(2025, 9, 23)),
    Expense(title: 'Tiket Bioskop', description: 'Nonton film baru', amount: 45000, category: 'Hiburan', date: DateTime(2025, 9, 24)),
    Expense(title: 'Paket Data', description: 'Kuota bulanan', amount: 120000, category: 'Kebutuhan', date: DateTime(2025, 8, 28)),
    Expense(title: 'Parkir', description: 'Parkir di mall', amount: 5000, category: 'Transportasi', date: DateTime(2025, 9, 24)),
    Expense(title: 'Makan Siang', description: 'Warung padang', amount: 28000, category: 'Makanan', date: DateTime(2025, 8, 20)),
    Expense(title: 'Beli Buku', description: 'Buku pemrograman', amount: 95000, category: 'Pendidikan', date: DateTime(2025, 9, 15)),
    Expense(title: 'Listrik', description: 'Token listrik', amount: 150000, category: 'Utilitas', date: DateTime(2025, 9, 5)),
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Urutkan data dari yang terbaru
    _allExpenses.sort((a, b) => b.date.compareTo(a.date));
    _filteredExpenses = _allExpenses;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExpenses() {
    setState(() {
      _filteredExpenses = _allExpenses.where((expense) {
        bool matchesSearch = _searchController.text.isEmpty ||
            expense.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            expense.description.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesCategory = _selectedCategory == 'Semua' ||
            expense.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Daftar Pengeluaran'),
        backgroundColor: Colors.teal,
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

          // Category filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  selectedColor: Colors.teal.withOpacity(0.3),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                      _filterExpenses();
                    });
                  },
                ),
              )).toList(),
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