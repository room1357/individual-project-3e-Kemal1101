// Kelas Expense disalin dari expense_screen.dart untuk referensi
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

class LoopingExamples {
  static List<Expense> expenses = [
    Expense(title: 'Kopi Susu', description: 'Meeting dengan klien', amount: 25000, category: 'Makanan', date: DateTime(2025, 9, 22)),
    Expense(title: 'Nasi Goreng', description: 'Makan malam', amount: 35000, category: 'Makanan', date: DateTime(2025, 9, 22)),
    Expense(title: 'Bensin Motor', description: 'Isi full tank', amount: 50000, category: 'Transportasi', date: DateTime(2025, 9, 23)),
    Expense(title: 'Tiket Bioskop', description: 'Nonton film baru', amount: 45000, category: 'Hiburan', date: DateTime(2025, 9, 24)),
    Expense(title: 'Paket Data', description: 'Kuota bulanan', amount: 120000, category: 'Kebutuhan', date: DateTime(2025, 8, 28)),
  ];

  // 1. Menghitung total dengan berbagai cara
  
  // Cara 1: For loop tradisional
  static double calculateTotalTraditional(List<Expense> expenses) {
    double total = 0;
    for (int i = 0; i < expenses.length; i++) {
      total += expenses[i].amount;
    }
    return total;
  }

  // Cara 2: For-in loop
  static double calculateTotalForIn(List<Expense> expenses) {
    double total = 0;
    for (Expense expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  // Cara 3: forEach method
  static double calculateTotalForEach(List<Expense> expenses) {
    double total = 0;
    expenses.forEach((expense) {
      total += expense.amount;
    });
    return total;
  }

  // Cara 4: fold method (paling efisien dan ringkas)
  static double calculateTotalFold(List<Expense> expenses) {
    // Menggunakan 0.0 untuk memastikan tipe data double
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Cara 5: reduce method
  static double calculateTotalReduce(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    // map untuk mengubah list of Expense menjadi list of double, lalu reduce
    return expenses.map((e) => e.amount).reduce((a, b) => a + b);
  }

  // 2. Mencari item dengan berbagai cara (menggunakan 'title' sebagai ID unik)
  
  // Cara 1: For loop dengan break
  static Expense? findExpenseTraditional(List<Expense> expenses, String title) {
    Expense? foundExpense;
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].title == title) {
        foundExpense = expenses[i];
        break; // Keluar dari loop setelah item ditemukan
      }
    }
    return foundExpense;
  }

  // Cara 2: firstWhere method (lebih modern)
  static Expense? findExpenseWhere(List<Expense> expenses, String title) {
    try {
      // orElse: null akan dikembalikan jika tidak ada yang cocok, menghindari error
      return expenses.firstWhere((expense) => expense.title == title);
    } catch (e) {
      // firstWhere akan melempar error jika tidak ada elemen yang cocok.
      // Penggunaan try-catch atau orElse dianjurkan.
      return null;
    }
  }

  // 3. Filtering dengan berbagai cara
  
  // Cara 1: Loop manual dengan List.add()
  static List<Expense> filterByCategoryManual(List<Expense> expenses, String category) {
    List<Expense> result = [];
    for (Expense expense in expenses) {
      if (expense.category.toLowerCase() == category.toLowerCase()) {
        result.add(expense);
      }
    }
    return result;
  }

  // Cara 2: where method (lebih efisien dan deklaratif)
  static List<Expense> filterByCategoryWhere(List<Expense> expenses, String category) {
    return expenses.where((expense) => 
      expense.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }
}

// --- ENTRY POINT UNTUK EKSEKUSI FILE INI SECARA MANDIRI ---
void main() {
  print('--- Menjalankan Tes Logika dari looping_examples.dart ---');
  
  // 1. Menghitung total
  print('\n--- Menghitung Total ---');
  print('For Tradisional: ${LoopingExamples.calculateTotalTraditional(LoopingExamples.expenses)}');
  print('For-In: ${LoopingExamples.calculateTotalForIn(LoopingExamples.expenses)}');
  print('forEach: ${LoopingExamples.calculateTotalForEach(LoopingExamples.expenses)}');
  print('fold: ${LoopingExamples.calculateTotalFold(LoopingExamples.expenses)}');
  print('reduce: ${LoopingExamples.calculateTotalReduce(LoopingExamples.expenses)}');

  // 2. Mencari item
  print('\n--- Mencari Item ---');
  final foundExpense = LoopingExamples.findExpenseWhere(LoopingExamples.expenses, 'Tiket Bioskop');
  if (foundExpense != null) {
    print('Ditemukan: ${foundExpense.title} - Rp ${foundExpense.amount}');
  } else {
    print('Item "Tiket Bioskop" tidak ditemukan.');
  }

  // 3. Filtering
  print('\n--- Filtering Kategori "Makanan" ---');
  final foodExpenses = LoopingExamples.filterByCategoryWhere(LoopingExamples.expenses, 'Makanan');
  foodExpenses.forEach((expense) {
    print(' - ${expense.title} (${expense.category})');
  });
  
  print('\n--- Tes Selesai ---');
}
