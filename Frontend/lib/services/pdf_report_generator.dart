// lib/services/pdf_report_generator.dart

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/models/earning_model.dart';

class PDFReportGenerator {
  static Future<Uint8List> generateReport({
    required EarningsSummary summary,
    required List<EarningModel> history,
    required String period,
    required String driverName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(context, driverName, period),
              pw.SizedBox(height: 20),
              _buildSummary(context, summary),
              pw.SizedBox(height: 20),
              _buildChart(context, summary),
              pw.SizedBox(height: 20),
              _buildHistoryTable(context, history),
              pw.SizedBox(height: 20),
              _buildFooter(context),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Context context, String driverName, String period) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '📊 Earnings Report',
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Driver: $driverName',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
        ),
        pw.Text(
          'Period: ${period.toUpperCase()}',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
        ),
        pw.Text(
          'Generated: ${DateTime.now().toLocal().toString().split('.')[0]}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey500),
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildSummary(pw.Context context, EarningsSummary summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('💰 Total', '\$${summary.totalEarnings.toStringAsFixed(2)}'),
              _buildSummaryItem('📦 Deliveries', summary.totalDeliveries.toString()),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('⭐ Rating', summary.averageRating.toStringAsFixed(1)),
              _buildSummaryItem('📈 Average/Day', '\$${summary.averagePerDay.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildChart(pw.Context context, EarningsSummary summary) {
    final totalDeliveries = summary.totalDeliveries;
    final pending = 0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            '📊 Deliveries Overview',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              _buildStatBox('Completed', totalDeliveries.toString(), PdfColors.green700),
              pw.SizedBox(width: 20),
              _buildStatBox('Pending', pending.toString(), PdfColors.orange700),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Total: $totalDeliveries',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatBox(String label, String value, PdfColor color) {
    final lightColor = color == PdfColors.green700 
        ? PdfColors.green100 
        : PdfColors.orange100;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHistoryTable(pw.Context context, List<EarningModel> history) {
    if (history.isEmpty) {
      return pw.Text('No transactions yet.');
    }

    return pw.Column(
      children: [
        pw.Text(
          '📋 Transaction History',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: ['Date', 'Customer', 'Amount', 'Status'],
          data: history.take(20).map((e) => [
            '${e.date.day}/${e.date.month}',
            e.customerName,
            '\$${e.total.toStringAsFixed(2)}',
            e.statusText,
          ]).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated by PickNGo Driver App • ${DateTime.now().year}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}