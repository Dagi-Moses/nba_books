import 'package:flutter/material.dart';
import 'package:nba_book_catalogue/components/delete_confirmation.dart';
import 'package:nba_book_catalogue/data_sources/book_data_source.dart';
import 'package:nba_book_catalogue/services/export.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class BuildTable extends StatelessWidget {
  const BuildTable({
    super.key,
    required this.dataSource,
    required this.isEditing,
  });

  final BookDataSource dataSource;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
      source: dataSource,
      key: exportKey,
      navigationMode: GridNavigationMode.cell,
      columnWidthMode: ColumnWidthMode.fill,

      selectionMode: SelectionMode.singleDeselect,

      allowEditing: isEditing,
      allowSwiping: isEditing,
      swipeMaxOffset: 100.0,

      showSortNumbers: true,

      allowFiltering: true,

      columnResizeMode: ColumnResizeMode.onResize,

      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      editingGestureType: EditingGestureType.tap,

      allowSorting: true,
      endSwipeActionsBuilder: (
        BuildContext context,
        DataGridRow row,
        int rowIndex,
      ) {
        return GestureDetector(
          onTap: () {
            final itemName =
                row
                    .getCells()
                    .firstWhere((cell) => cell.columnName == 'title')
                    .value
                    .toString();

            deleteItemDialog(context, itemName, () async {
              print('Row index: $rowIndex');
              print('Total books: ${dataSource.books.length}');
              print('Row data: ${dataSource.books[rowIndex]}');

              final bookId =
                  row
                      .getCells()
                      .firstWhere((c) => c.columnName == 'id')
                      .value
                      .toString();
              print('Book id: $bookId');
              try {
                await Supabase.instance.client
                    .from('books')
                    .delete()
                    .eq('id', bookId);

                Navigator.of(context).pop(); // close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "$itemName" successfully')),
                );
              } catch (e) {
                print(e.toString());
                Navigator.of(context).pop(); // close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete "$itemName": $e')),
                );
              }
            });
          },
          child: Container(
            color: Colors.redAccent,
            child: const Center(child: Icon(Icons.delete, color: Colors.white)),
          ),
        );
      },

      columns: <GridColumn>[
        GridColumn(
          columnName: 'isbn',
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('ISBN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        GridColumn(
          columnName: 'title',
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        GridColumn(
          columnName: 'author',
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Author',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        GridColumn(
          maximumWidth: 100,
          columnName: 'dateOfPublication',
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('Date ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        GridColumn(
          columnName: 'publisher',
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Publisher',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        GridColumn(
          columnName: 'classification',
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Classification',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        GridColumn(
          columnName: 'subject',
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Subject',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
