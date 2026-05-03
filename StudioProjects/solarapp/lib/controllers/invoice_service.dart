import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/isar/solar_transaction.dart';

class InvoiceService {
  static Future<Uint8List> buildPdf({required SolarTransaction tx}) async {
    final doc = pw.Document();

    final primary = PdfColor.fromInt(0xFF4489F7);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 36,
                        height: 36,
                        decoration: pw.BoxDecoration(
                          color: primary,
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'S',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Solar Inventory',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Invoice',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Text(
                    '#${tx.code}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Container(height: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 14),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        tx.kind == TransactionKind.purchase
                            ? 'Supplier'
                            : 'Customer',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(tx.contactName),
                      if ((tx.contactPhone ?? '').isNotEmpty)
                        pw.Text(tx.contactPhone!),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Transaction',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(tx.code),
                      pw.Text(_formatDateTime(tx.timestamp)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'Items',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1.2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  _tableHeader(primary),
                  _tableRow(tx: tx),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 240,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      _kv('Subtotal', _money(tx.totalAmount)),
                      pw.SizedBox(height: 6),
                      _kv('Amount Paid', _money(tx.amountPaid)),
                      pw.SizedBox(height: 6),
                      _kv(
                        'Remaining Balance',
                        _money(tx.remainingBalance),
                        valueStyle: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: tx.remainingBalance > 0
                              ? PdfColors.red800
                              : PdfColors.green800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Spacer(),
              pw.Container(height: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Solar Inventory Management System v1.0',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    _formatDateTime(DateTime.now()),
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static Future<void> shareInvoice({required SolarTransaction tx}) async {
    final bytes = await buildPdf(tx: tx);
    await Printing.sharePdf(bytes: bytes, filename: 'invoice_${tx.code}.pdf');
  }

  static Future<void> printInvoice({required SolarTransaction tx}) async {
    final bytes = await buildPdf(tx: tx);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static pw.TableRow _tableHeader(PdfColor primary) {
    pw.Widget cell(String t) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        t,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: primary,
          fontSize: 10,
        ),
      ),
    );

    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        cell('Panel Name'),
        cell('Watts'),
        cell('Qty'),
        cell('Price/W'),
        cell('Line Total'),
      ],
    );
  }

  static pw.TableRow _tableRow({required SolarTransaction tx}) {
    pw.Widget cell(String t, {pw.TextAlign align = pw.TextAlign.left}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            t,
            textAlign: align,
            style: const pw.TextStyle(fontSize: 10),
          ),
        );

    final lineTotal = tx.totalAmount;

    return pw.TableRow(
      children: [
        cell(tx.panelName),
        cell('${tx.wattsPerPanel}W', align: pw.TextAlign.right),
        cell('${tx.quantity}', align: pw.TextAlign.right),
        cell(_money(tx.pricePerWatt), align: pw.TextAlign.right),
        cell(_money(lineTotal), align: pw.TextAlign.right),
      ],
    );
  }

  static pw.Widget _kv(String k, String v, {pw.TextStyle? valueStyle}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          k,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Text(
          v,
          style:
              valueStyle ??
              pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static String _money(double v) => 'Rs ${v.toStringAsFixed(0)}';

  static String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}
