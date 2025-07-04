import 'package:nba_book_catalogue/services/export.dart';
import 'package:flutter/material.dart';

class ExportButton extends StatelessWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: PopupMenuButton<String>(
        onSelected: handleExport,

        itemBuilder:
            (ctx) => [
              PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
              PopupMenuItem(value: 'excel', child: Text('Export as Excel')),
            ],
        child: AbsorbPointer(
          child: ElevatedButton.icon(
            icon: Icon(Icons.upload_file),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            label: Text('Export', style: TextStyle(color: Colors.black)),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
