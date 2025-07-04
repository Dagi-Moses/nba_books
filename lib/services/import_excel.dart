import 'dart:html' as html;
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nba_book_catalogue/providers/classifications_provider.dart';
import 'package:nba_book_catalogue/providers/subject_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nba_book_catalogue/models/book_model.dart';

pickExcelFileAndImport(WidgetRef ref) {
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.accept = '.xlsx';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);
      reader.onLoadEnd.listen((e) async {
        final data = reader.result as Uint8List;
        await importBooksFromExcel(data, ref);
      });
    }
  });
}

handleImport(String value, WidgetRef ref) async {
  switch (value) {
    case 'excel':
      await pickExcelFileAndImport(ref);
      break;
    default:
      print('Unknown export format: $value');
  }
}

Future<void> importBooksFromExcel(Uint8List data, WidgetRef ref) async {
  try {
    final classifications = ref.read(classificationsProvider).value ?? [];
    final subjects = ref.read(subjectsProvider).value ?? [];

    final classificationMap = {for (var c in classifications) c.id: c.name};
    final subjectMap = {for (var s in subjects) s.id: s.name};

    final excel = Excel.decodeBytes(data);

    final sheet = excel.tables.keys.first;
    final rows = excel.tables[sheet]?.rows ?? [];

    if (rows.length <= 1) {
      Fluttertoast.showToast(
        msg: "No data rows found in the Excel sheet.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    Fluttertoast.showToast(
      msg: "Importing books...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    for (var row in rows.skip(1)) {
      final isbn = row[0]?.value.toString().trim() ?? '';
      final title = row[1]?.value.toString().trim() ?? '';
      final author = row[2]?.value.toString().trim() ?? '';
      final yearString = row[3]?.value.toString().trim() ?? '';
      final publisher = row[4]?.value.toString().trim() ?? '';
      final classificationName = row[5]?.value.toString().trim() ?? '';
      final subjectName = row[6]?.value.toString().trim() ?? '';

      if (title.isEmpty || author.isEmpty) {
        Fluttertoast.showToast(
          msg: "Skipping row with missing title or author.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        continue;
      }

      final publicationYear = int.tryParse(yearString) ?? 0;

      final classificationId =
          classificationMap.entries
              .firstWhere(
                (entry) =>
                    entry.value.toLowerCase() ==
                    classificationName.toLowerCase(),
                orElse: () => const MapEntry(0, ''),
              )
              .key;

      final subjectId =
          subjectMap.entries
              .firstWhere(
                (entry) =>
                    entry.value.toLowerCase() == subjectName.toLowerCase(),
                orElse: () => const MapEntry(0, ''),
              )
              .key;

      final book = Book(
        id: 0, // Supabase will auto-generate
        title: title,
        author: author,
        publisher: publisher,
        publicationDate: publicationYear,
        isbn: isbn,
        classificationId: classificationId,
        subjectId: subjectId,
        createdAt: DateTime.now(),
      );

      try {
        await Supabase.instance.client.from('books').insert(book.toMap());
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Failed to import book \"$title\": ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        // continue importing the rest even if one fails
      }
    }

    Fluttertoast.showToast(
      msg: "Books import completed successfully.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  } catch (e) {
    print("ERROR: ${e.toString()}");
    Fluttertoast.showToast(
      msg: "Error during import: ${e.toString()}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
    );
  }
}
