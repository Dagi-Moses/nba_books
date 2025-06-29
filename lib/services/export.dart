import 'dart:html' as html;
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

final GlobalKey<SfDataGridState> exportKey = GlobalKey<SfDataGridState>();

void handleExport(String value) async {
  switch (value) {
    case 'pdf':
      await exportAsPDF();
      break;
    case 'excel':
      await exportAsExcelWeb();
      break;
    default:
      print('Unknown export format: $value');
  }
}

Future<void> exportAsExcelWeb() async {
  final Workbook workbook = exportKey.currentState!.exportToExcelWorkbook();
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  final blob = html.Blob([Uint8List.fromList(bytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor =
      html.AnchorElement(href: url)
        ..setAttribute('download', 'NBA_Book_DataBase.xlsx')
        ..click();
  html.Url.revokeObjectUrl(url);
}

Future<void> exportAsPDF() async {
  final PdfDocument document = exportKey.currentState!.exportToPdfDocument(
    autoColumnWidth: true,
    fitAllColumnsInOnePage: true,
  );

  final List<int> bytes = await document.save();
  document.dispose();

  final blob = html.Blob([Uint8List.fromList(bytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor =
      html.AnchorElement(href: url)
        ..setAttribute('download', 'NBA_Book_Catalogue.pdf')
        ..click();
  html.Url.revokeObjectUrl(url);
}
