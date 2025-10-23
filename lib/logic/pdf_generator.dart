import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; // Impor kIsWeb
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart'; // Impor package printing
import '../models/expense_model.dart';

class PdfExportService {
  // Fungsi utama yang akan dipanggil dari UI
  static Future<void> createAndOpenPdf(List<Expense> expenses, String period) async {
    final pdf = await _generatePdf(expenses, period);
    final bytes = await pdf.save();

    if (kIsWeb) {
      // Untuk Web: Tampilkan PDF di tab baru untuk di-download atau dicetak
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
    } else {
      // Untuk Mobile/Desktop: Simpan file dan buka
      final file = await _saveDocument(name: 'Laporan-Pengeluaran-$period.pdf', pdfBytes: bytes);
      await _openFile(file);
    }
  }

  // Fungsi ini sekarang private dan hanya membuat dokumen di memori
  static Future<pw.Document> _generatePdf(List<Expense> expenses, String period) async {
    final pdf = pw.Document();
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final total = expenses.fold(0.0, (sum, item) => sum + item.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            _buildHeader(period),
            pw.SizedBox(height: 20),
            _buildSummary(expenses.length, total, currencyFormat),
            pw.SizedBox(height: 20),
            _buildExpenseTable(expenses, currencyFormat),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10.0),
            child: pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(color: PdfColors.grey),
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(String period) {
    // ... (Tidak ada perubahan di sini)
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Laporan Pengeluaran',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Periode: $period',
          style: const pw.TextStyle(fontSize: 16),
        ),
        pw.Divider(height: 20),
      ],
    );
  }

  static pw.Widget _buildSummary(int count, double total, NumberFormat format) {
    // ... (Tidak ada perubahan di sini)
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Ringkasan:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Jumlah Transaksi:'),
            pw.Text(count.toString()),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Pengeluaran:'),
            pw.Text(format.format(total), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildExpenseTable(List<Expense> expenses, NumberFormat format) {
    // ... (Tidak ada perubahan di sini)
    final headers = ['No', 'Tanggal', 'Judul', 'Kategori', 'Jumlah'];
    final data = expenses.asMap().entries.map((entry) {
      final index = entry.key;
      final expense = entry.value;
      return [
        (index + 1).toString(),
        expense.formattedDate,
        expense.title,
        expense.categoryName,
        format.format(expense.amount),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
      },
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }

  // Fungsi ini sekarang menerima byte, bukan dokumen
  static Future<File> _saveDocument({
    required String name,
    required Uint8List pdfBytes,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  static Future<void> _openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}