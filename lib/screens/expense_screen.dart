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
  ];

  // Fungsi-fungsi lain tidak berubah...
  static Map<String, double> getTotalByCategory(List<Expense> expenses) {
    Map<String, double> result = {};
    for (var expense in expenses) {
      result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }
  static Expense? getHighestExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }
  static List<Expense> getExpensesByMonth(List<Expense> expenses, int month, int year) {
    return expenses.where((expense) =>
      expense.date.month == month && expense.date.year == year
    ).toList();
  }
  static List<Expense> searchExpenses(List<Expense> expenses, String keyword) {
    if (keyword.isEmpty) {
      return expenses; // Kembalikan semua jika keyword kosong
    }
    String lowerKeyword = keyword.toLowerCase();
    return expenses.where((expense) =>
      expense.title.toLowerCase().contains(lowerKeyword) ||
      expense.description.toLowerCase().contains(lowerKeyword) ||
      expense.category.toLowerCase().contains(lowerKeyword)
    ).toList();
  }
  static double getAverageDaily(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    double total = expenses.fold(0, (sum, expense) => sum + expense.amount);
    Set<String> uniqueDays = expenses.map((expense) => 
      '${expense.date.year}-${expense.date.month}-${expense.date.day}'
    ).toSet();
    if (uniqueDays.isEmpty) return 0;
    return total / uniqueDays.length;
  }
}


// --- UI SCREEN (Diubah menjadi StatefulWidget) ---
class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // 1. Variabel State untuk menyimpan input dan hasil
  late TextEditingController _searchController;
  List<Expense> _searchResults = [];
  List<Expense> _monthlyExpenses = [];

  // Mendapatkan waktu saat ini untuk nilai default
  final DateTime now = DateTime.now();
  late int _selectedMonth;
  late int _selectedYear;

  // 2. initState: Dijalankan sekali saat widget pertama kali dibuat
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Atur nilai awal untuk filter bulan & tahun
    _selectedMonth = now.month;
    _selectedYear = now.year;

    // Panggil filter awal saat layar pertama kali dibuka
    _runFilters();
  }

  // 3. dispose: Membersihkan controller saat widget dihancurkan
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 4. Fungsi untuk menjalankan semua filter dan memperbarui UI
  void _runFilters() {
    setState(() {
      // Filter berdasarkan kata kunci pencarian
      _searchResults = ExpenseManager.searchExpenses(
        ExpenseManager.expenses,
        _searchController.text,
      );
      // Filter berdasarkan bulan dan tahun yang dipilih
      _monthlyExpenses = ExpenseManager.getExpensesByMonth(
        ExpenseManager.expenses,
        _selectedMonth,
        _selectedYear,
      );
    });
  }

  // Helper untuk format mata uang
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // Data yang tidak interaktif bisa tetap di sini
    final totalByCategory = ExpenseManager.getTotalByCategory(ExpenseManager.expenses);
    final highestExpense = ExpenseManager.getHighestExpense(ExpenseManager.expenses);
    final averageDaily = ExpenseManager.getAverageDaily(ExpenseManager.expenses);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Analisis Pengeluaran'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KONTROL INTERAKTIF ---

            // Input untuk Pencarian
            TextField(
              controller: _searchController,
              onChanged: (value) => _runFilters(), // Panggil filter setiap kali teks berubah
              decoration: InputDecoration(
                labelText: 'Cari pengeluaran...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Input untuk Filter Bulan & Tahun
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(labelText: 'Bulan'),
                    items: List.generate(12, (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(0, index + 1))),
                    )),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedMonth = value;
                        _runFilters();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(labelText: 'Tahun'),
                    items: [2024, 2025, 2026].map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedYear = value;
                        _runFilters();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- TAMPILAN HASIL (sekarang menggunakan variabel state) ---
            
            // Tampilan Hasil Pencarian
            _buildInfoCard(
              title: 'Hasil Pencarian untuk "${_searchController.text}"',
              icon: Icons.search,
              content: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                children: _searchResults.isNotEmpty
                    ? _searchResults.map((e) => Text('${e.title} (${_formatCurrency(e.amount)})')).toList()
                    : [const Text('Tidak ada hasil.')],
              ),
            ),
            const SizedBox(height: 16),

            // Tampilan Pengeluaran Bulan yang Dipilih
            _buildInfoCard(
              title: 'Pengeluaran Bulan ${DateFormat('MMMM', 'id_ID').format(DateTime(0, _selectedMonth))} $_selectedYear',
              icon: Icons.calendar_month,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _monthlyExpenses.isNotEmpty
                    ? _monthlyExpenses.map((e) => Text('${e.title}: ${_formatCurrency(e.amount)}')).toList()
                    : [const Text('Tidak ada pengeluaran di bulan ini.')],
              ),
            ),
            const SizedBox(height: 16),
            
            // Tampilan data yang tidak interaktif (tetap sama)
            _buildInfoCard(
              title: 'Total per Kategori',
              icon: Icons.category,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: totalByCategory.entries.map((entry) {
                  return Text('${entry.key}: ${_formatCurrency(entry.value)}');
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Pengeluaran Tertinggi',
              icon: Icons.trending_up,
              content: highestExpense != null
                  ? Text('${highestExpense.title}: ${_formatCurrency(highestExpense.amount)}')
                  : const Text('Data tidak ditemukan'),
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Rata-rata Pengeluaran Harian',
              icon: Icons.calculate,
              content: Text(
                _formatCurrency(averageDaily),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Widget content}) {
    // ... (Fungsi ini tidak berubah)
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            content,
          ],
        ),
      ),
    );
  }
}