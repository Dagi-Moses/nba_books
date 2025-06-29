// import 'package:nba_book_catalogue/models/book_model.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:excel/excel.dart';

// Future<List<Book>> importFromExcel() async {
//   final result = await FilePicker.platform.pickFiles(
//     type: FileType.custom,
//     allowedExtensions: ['xlsx'],
//     withData: true, // Important for web!
//   );

//   if (result == null || result.files.single.bytes == null) return [];

//   final bytes = result.files.single.bytes!;
//   final excel = Excel.decodeBytes(bytes);

//   final sheet = excel.tables[excel.tables.keys.first];
//   if (sheet == null) return [];

//   final books = <Book>[];

//   for (var i = 1; i < sheet.rows.length; i++) {
//     final row = sheet.rows[i];
//     try {
//       books.add(
//         Book(
//           title: row[0]?.value.toString() ?? '',
//           author: row[1]?.value.toString() ?? '',
//           publisher: row[2]?.value.toString() ?? '',
//           subject: row[3]?.value.toString() ?? '',
//           publicationDate: DateTime.parse(row[4]?.value.toString() ?? ''),
//         ),
//       );
//     } catch (_) {}
//   }

//   return books;
// }

// // final importedBooks = await importFromExcel();
// // ref.read(bookListProvider.notifier).state = importedBooks;
