// lib/services/rating_report_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/constants/api_constants.dart';
import '../services/storage_service.dart';
import 'dart:html' as html if (dart.library.html) 'dart:html';

class RatingReportService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();
  
  final Future<pw.Font> font = PdfGoogleFonts.cairoRegular();
  final Future<pw.Font> fontBold = PdfGoogleFonts.cairoBold();

  RatingReportService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _getReportData(DateTime month) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/ratings/driver/report', 
        queryParameters: {
          'year': month.year,
          'month': month.month,
        },
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return {};
    } catch (e) {
      print('❌ Get report data error: $e');
      return {};
    }
  }

  Future<File> generateRatingReport(DateTime month) async {
    try {
      final data = await _getReportData(month);
      final pdf = pw.Document();
      
      final loadedFont = await font;
      final loadedFontBold = await fontBold;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(context, month, loadedFont, loadedFontBold),
                pw.SizedBox(height: 20),
                _buildSummary(context, data, loadedFont, loadedFontBold),
                pw.SizedBox(height: 20),
                _buildSentimentChart(context, data, loadedFont, loadedFontBold),
                pw.SizedBox(height: 20),
                _buildCityBreakdown(context, data, loadedFont, loadedFontBold),
                pw.SizedBox(height: 20),
                _buildRatingsTable(context, data, loadedFont, loadedFontBold),
                pw.SizedBox(height: 20),
                _buildFooter(context, loadedFont),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      if (kIsWeb) {
        final base64 = base64Encode(bytes);
        final anchor = html.AnchorElement(
          href: 'data:application/pdf;base64,$base64'
        )
          ..target = '_blank'
          ..download = 'rating_report_${month.year}_${month.month.toString().padLeft(2, '0')}.pdf'
          ..click();
        return File('');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'rating_report_${month.year}_${month.month.toString().padLeft(2, '0')}.pdf';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      print('✅ Report saved to: $filePath');
      return file;

    } catch (e) {
      print('❌ Generate rating report error: $e');
      rethrow;
    }
  }

  pw.Widget _buildHeader(
    pw.Context context,
    DateTime month,
    pw.Font loadedFont,
    pw.Font loadedFontBold,
  ) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Monthly Rating Report',
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
            font: loadedFontBold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${monthNames[month.month - 1]} ${month.year}',
          style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700, font: loadedFont),
        ),
        pw.Text(
          'Generated: ${DateTime.now().toLocal().toString().split('.')[0]}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey500, font: loadedFont),
        ),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildSummary(
    pw.Context context,
    Map<String, dynamic> data,
    pw.Font loadedFont,
    pw.Font loadedFontBold,
  ) {
    final summary = data['summary'] ?? {};

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: [
          _summaryItem('Avg Rating', summary['average_rating']?.toStringAsFixed(1) ?? '0', loadedFontBold),
          _summaryItem('Total', summary['total_ratings']?.toString() ?? '0', loadedFontBold),
          _summaryItem('Positive', '${summary['positive_percentage'] ?? 0}%', loadedFontBold),
        ],
      ),
    );
  }

  pw.Widget _summaryItem(String label, String value, pw.Font loadedFontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: loadedFontBold)),
      ],
    );
  }

  pw.Widget _buildSentimentChart(
    pw.Context context,
    Map<String, dynamic> data,
    pw.Font loadedFont,
    pw.Font loadedFontBold,
  ) {
    final sentiment = data['sentiment_breakdown'] ?? {
      'positive': 0,
      'neutral': 0,
      'negative': 0,
    };

    final total = (sentiment['positive'] ?? 0) + 
                   (sentiment['neutral'] ?? 0) + 
                   (sentiment['negative'] ?? 0);

    if (total == 0) {
      return pw.Text('No data available for sentiment analysis');
    }

    return pw.Column(
      children: [
        pw.Text(
          'Sentiment Distribution',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: loadedFontBold),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            _sentimentBar('Positive', sentiment['positive'] ?? 0, total, PdfColors.green700, loadedFont),
            pw.SizedBox(width: 8),
            _sentimentBar('Neutral', sentiment['neutral'] ?? 0, total, PdfColors.orange700, loadedFont),
            pw.SizedBox(width: 8),
            _sentimentBar('Negative', sentiment['negative'] ?? 0, total, PdfColors.red700, loadedFont),
          ],
        ),
      ],
    );
  }

  pw.Widget _sentimentBar(String label, int count, int total, PdfColor color, pw.Font loadedFont) {
    final double percentage = total > 0 ? (count / total) * 100.0 : 0.0;

    return pw.Column(
      children: [
        pw.Text(
          '$count',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          width: 60,
          height: 120,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Stack(
            alignment: pw.Alignment.bottomCenter,
            children: [
              pw.Container(
                height: percentage,
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${percentage.toStringAsFixed(0)}%',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, font: loadedFont),
        ),
      ],
    );
  }

  pw.Widget _buildCityBreakdown(
    pw.Context context,
    Map<String, dynamic> data,
    pw.Font loadedFont,
    pw.Font loadedFontBold,
  ) {
    final cities = data['cities'] ?? {};

    if (cities.isEmpty) {
      return pw.Text('No city data available');
    }

    return pw.Column(
      children: [
        pw.Text(
          'City Breakdown',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: loadedFontBold),
        ),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: ['City', 'Rating', 'Reviews', 'Sentiment'],
          data: cities.entries.map((entry) {
            final city = entry.value;
            return [
              entry.key,
              city['average_rating']?.toStringAsFixed(1) ?? '0',
              city['total_ratings']?.toString() ?? '0',
              '${city['positive_percentage'] ?? 0}%',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            font: loadedFontBold,
          ),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ],
    );
  }

  pw.Widget _buildRatingsTable(
    pw.Context context,
    Map<String, dynamic> data,
    pw.Font loadedFont,
    pw.Font loadedFontBold,
  ) {
    final ratings = data['ratings'] ?? [];

    if (ratings.isEmpty) {
      return pw.Text('No ratings found for this period');
    }

    return pw.Column(
      children: [
        pw.Text(
          'Recent Ratings',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: loadedFontBold),
        ),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: ['Date', 'Customer', 'Rating', 'Comment'],
          data: ratings.take(20).map((rating) => [
            rating['date']?.split('T')[0] ?? '',
            rating['customer_name'] ?? '',
            '${rating['rating'] ?? 0}',
            rating['comment'] ?? '',
          ]).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            font: loadedFontBold,
          ),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font loadedFont) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated by PickNGo Driver App • ${DateTime.now().year}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500, font: loadedFont),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}