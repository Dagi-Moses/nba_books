import 'package:nba_book_catalogue/data_sources/book_data_source.dart';
import 'package:nba_book_catalogue/services/export.dart';
import 'package:flutter/widgets.dart';
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
      // allowColumnsResizing: true,
      // showCheckboxColumn: true,
      selectionMode: SelectionMode.singleDeselect,
      //showColumnHeaderIconOnHover: true,
      // allowColumnsDragging: true,
      allowEditing: isEditing,
      //allowMultiColumnSorting: true,
      showSortNumbers: true,

      allowFiltering: true,
      // allowPullToRefresh: true,
      // allowSwiping: true,
      columnResizeMode: ColumnResizeMode.onResize,
      //  editingGestureType: EditingGestureType.doubleTap,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      editingGestureType: EditingGestureType.tap,

      // selectionMode: SelectionMode.single,
      allowSorting: true,

      columns: <GridColumn>[
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
          columnName: 'dateOfPublication',
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Date of Plublification',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
