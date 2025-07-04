import 'package:nba_book_catalogue/models/book_model.dart';
import 'package:nba_book_catalogue/services/update_book.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];
  List<Book> books = [];

  final Map<int, String> subjectMap;
  final Map<int, String> classificationMap;
  final String query;
  final BuildContext context;

  final supabase = Supabase.instance.client;

  Book? getBookAtRow(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= books.length) return null;
    return books[rowIndex];
  }

  BookDataSource(
    List<Book> books,
    this.context, {
    required this.subjectMap,
    required this.classificationMap,
    required this.query,
  }) {
    updateData(books);
  }

  void updateData(List<Book> newBooks) {
    books = newBooks;
    dataGridRows =
        books.map<DataGridRow>((book) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'isbn', value: book.isbn),
              DataGridCell<String>(columnName: 'title', value: book.title),

              DataGridCell<String>(columnName: 'author', value: book.author),
              DataGridCell<String>(
                columnName: 'dateOfPublication',
                value: book.publicationDate.toString(),
              ),
              DataGridCell<String>(
                columnName: 'publisher',
                value: book.publisher,
              ),
              DataGridCell<String>(
                columnName: 'classification',
                value: classificationMap[book.classificationId] ?? '',
              ),
              DataGridCell<String>(
                columnName: 'subject',
                value: subjectMap[book.subjectId] ?? '',
              ),
            ],
          );
        }).toList();

    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((cell) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: _highlightMatch(cell.value.toString()),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
    );
  }

  TextSpan _highlightMatch(String text) {
    if (query.trim().isEmpty) return TextSpan(text: text);
    final lcText = text.toLowerCase();
    final lcQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;
    int matchIndex;

    while ((matchIndex = lcText.indexOf(lcQuery, start)) != -1) {
      if (matchIndex > start) {
        spans.add(TextSpan(text: text.substring(start, matchIndex)));
      }
      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + lcQuery.length),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = matchIndex + lcQuery.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return TextSpan(children: spans);
  }

  dynamic newCellValue;
  final TextEditingController editingController = TextEditingController();

  @override
  Future<void> onCellSubmit(
    DataGridRow row,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) async {
    final int rowIndex = rows.indexOf(row);
    final Book book = books[rowIndex];

    final String columnName = column.columnName;
    final dynamic oldValue =
        row.getCells().firstWhere((c) => c.columnName == columnName).value;

    if (newCellValue == null || newCellValue == oldValue) return;

    switch (columnName) {
      case 'isbn':
        book.isbn = newCellValue;
        break;
      case 'title':
        book.title = newCellValue;
        break;

      case 'author':
        book.author = newCellValue;
        break;
      case 'publisher':
        book.publisher = newCellValue;
        break;
      case 'dateOfPublication':
        book.publicationDate =
            int.tryParse(newCellValue.toString()) ?? book.publicationDate;
        break;
      case 'classification':
        final selectedClassId =
            classificationMap.entries
                .firstWhere(
                  (entry) => entry.value == newCellValue,
                  orElse: () => const MapEntry(0, ''),
                )
                .key;

        book.classificationId = selectedClassId;

        break;
      case 'subject':
        final selectedSubId =
            subjectMap.entries
                .firstWhere(
                  (entry) => entry.value == newCellValue,
                  orElse: () => const MapEntry(0, ''),
                )
                .key;

        book.subjectId = selectedSubId;

        break;
      default:
        break;
    }

    rows[rowIndex].getCells()[rowColumnIndex
        .columnIndex] = DataGridCell<String>(
      columnName: columnName,
      value: newCellValue.toString(),
    );
    updateBookOnSupabase(book: book);
  }

  // @override
  // Widget? buildEditWidget(
  //   DataGridRow dataGridRow,
  //   RowColumnIndex rowColumnIndex,
  //   GridColumn column,
  //   CellSubmit submitCell,
  // ) {
  //   final String columnName = column.columnName;
  //   final dynamic cellValue =
  //       dataGridRow
  //           .getCells()
  //           .firstWhere((c) => c.columnName == columnName)
  //           .value;

  //   newCellValue = null;

  //   switch (columnName) {
  //     case 'dateOfPublication':
  //       return InkWell(
  //         onTap: () async {
  //           int selectedYear =
  //               int.tryParse(cellValue.toString()) ?? DateTime.now().year;
  //           await showDialog(
  //             context: context,
  //             builder: (context) {
  //               return AlertDialog(
  //                 content: SizedBox(
  //                   width: 300,
  //                   height: 300,
  //                   child: YearPicker(
  //                     firstDate: DateTime(1900),
  //                     lastDate: DateTime(DateTime.now().year + 5),
  //                     selectedDate: DateTime(selectedYear),
  //                     onChanged: (DateTime dateTime) {
  //                       Navigator.pop(context);
  //                       newCellValue = dateTime.year;
  //                       submitCell();
  //                     },
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         },
  //         child: Container(
  //           alignment: Alignment.centerLeft,
  //           padding: const EdgeInsets.all(8),
  //           child: Text(cellValue.toString()),
  //         ),
  //       );

  //     case 'classification':
  //       return DropdownButton<String>(
  //         value: cellValue?.toString(),
  //         isExpanded: true,
  //         onChanged: (value) {
  //           newCellValue = value;
  //           submitCell();
  //         },
  //         items:
  //             [
  //               'Law',
  //               'Politics',
  //               'History',
  //               'Other',
  //             ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
  //       );

  //     default:
  //       return TextField(
  //         controller: editingController..text = cellValue?.toString() ?? '',
  //         autofocus: true,
  //         onChanged: (value) => newCellValue = value,
  //         onSubmitted: (_) => submitCell(),
  //         keyboardType: TextInputType.text,
  //         decoration: const InputDecoration(contentPadding: EdgeInsets.all(8)),
  //       );
  //   }
  // }
  @override
  Widget? buildEditWidget(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    final String columnName = column.columnName;
    final dynamic cellValue =
        dataGridRow
            .getCells()
            .firstWhere((c) => c.columnName == columnName)
            .value;

    newCellValue = null;

    switch (columnName) {
      case 'dateOfPublication':
        return InkWell(
          onTap: () async {
            int selectedYear =
                int.tryParse(cellValue.toString()) ?? DateTime.now().year;
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: SizedBox(
                    width: 300,
                    height: 300,
                    child: YearPicker(
                      firstDate: DateTime(1900),
                      lastDate: DateTime(DateTime.now().year + 5),
                      selectedDate: DateTime(selectedYear),
                      onChanged: (DateTime dateTime) {
                        Navigator.pop(context);
                        newCellValue = dateTime.year;
                        submitCell();
                      },
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8),
            child: Text(cellValue.toString()),
          ),
        );

      case 'classification':
        final classifications = classificationMap.values.toList();
        String currentValue = cellValue?.toString() ?? '';
        if (!classifications.contains(currentValue) &&
            classifications.isNotEmpty) {
          currentValue = classifications.first;
        }

        return DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          onChanged: (value) {
            if (value != null) {
              newCellValue = value;
              submitCell();
            }
          },
          items:
              classifications
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
        );

      case 'subject':
        final subjects = subjectMap.values.toList();
        String currentValue = cellValue?.toString() ?? '';
        if (!subjects.contains(currentValue) && subjects.isNotEmpty) {
          currentValue = subjects.first;
        }

        return DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          onChanged: (value) {
            if (value != null) {
              newCellValue = value;
              submitCell();
            }
          },
          items:
              subjects
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
        );

      default:
        editingController.text = cellValue?.toString() ?? '';
        return TextField(
          controller: editingController,
          autofocus: true,
          onChanged: (value) => newCellValue = value,
          onSubmitted: (_) => submitCell(),
          decoration: const InputDecoration(contentPadding: EdgeInsets.all(8)),
        );
    }
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
