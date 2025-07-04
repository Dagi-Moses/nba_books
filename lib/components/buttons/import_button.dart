import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:nba_book_catalogue/services/import_excel.dart';

class ImportButton extends ConsumerWidget {
  const ImportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: PopupMenuButton<String>(
        onSelected: (value) => handleImport(value, ref),

        itemBuilder:
            (ctx) => [
              PopupMenuItem(value: 'excel', child: Text('Import from Excel')),
            ],
        child: AbsorbPointer(
          child: ElevatedButton.icon(
            icon: Icon(Icons.download),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            label: Text('Import', style: TextStyle(color: Colors.black)),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
