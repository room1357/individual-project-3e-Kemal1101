import 'package:intl/intl.dart';

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

  String get title => judul;
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

  String get formattedAmount {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  String get formattedDate {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }
}
