import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Expense>> _expenseFuture;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Tambahkan state untuk filter
  late int _selectedYear;
  late int _selectedMonth;
  final List<int> _years =
      List.generate(5, (index) => DateTime.now().year - index); // 5 tahun terakhir
  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan bulan dan tahun saat ini
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _expenseFuture = _fetchExpenses();
  }

  Future<List<Expense>> _fetchExpenses() async {
    if (User.currentUser == null) {
      throw Exception('User not logged in');
    }
    // Tambahkan parameter tahun dan bulan ke URL
    final url = Uri.parse(
        'http://192.168.100.138/expenseapp/get_expense.php?user_id=${User.currentUser!.id}&year=$_selectedYear&month=$_selectedMonth');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          return [];
        }
        return data.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load expenses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals.update(
        expense.categoryName,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Pengeluaran'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expenseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada data pengeluaran untuk ditampilkan.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final expenses = snapshot.data!;
          final categoryTotals = _calculateCategoryTotals(expenses);
          final totalExpense =
              expenses.fold(0.0, (sum, item) => sum + item.amount);

          final List<Color> pieColors = [
            Colors.orange,
            Colors.blue,
            Colors.purple,
            Colors.green,
            Colors.indigo,
            Colors.red,
            Colors.amber,
            Colors.teal,
            Colors.pink,
            Colors.brown,
          ];

          int colorIndex = 0;
          final pieChartSections = categoryTotals.entries.map((entry) {
            final color = pieColors[colorIndex % pieColors.length];
            colorIndex++;
            return PieChartSectionData(
              color: color,
              value: entry.value,
              title: _currencyFormat.format(entry.value),
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Widget untuk filter
                _buildFilterSection(),
                const SizedBox(height: 24),
                Text(
                  'Total Pengeluaran',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  _currencyFormat.format(totalExpense),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Rincian Kategori',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildLegend(categoryTotals, pieColors),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget baru untuk filter
  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Dropdown Tahun
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedYear,
            items: _years.map((year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedYear = value;
                  _expenseFuture = _fetchExpenses(); // Panggil ulang future
                });
              }
            },
            decoration: const InputDecoration(
              labelText: 'Tahun',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Dropdown Bulan
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedMonth,
            items: List.generate(12, (index) {
              return DropdownMenuItem<int>(
                value: index + 1,
                child: Text(_months[index]),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMonth = value;
                  _expenseFuture = _fetchExpenses(); // Panggil ulang future
                });
              }
            },
            decoration: const InputDecoration(
              labelText: 'Bulan',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(Map<String, double> categoryTotals, List<Color> colors) {
    int colorIndex = 0;
    return Column(
      children: categoryTotals.entries.map((entry) {
        final color = colors[colorIndex % colors.length];
        colorIndex++;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Text(
                _currencyFormat.format(entry.value),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
