import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nba_book_catalogue/components/manage_types.dart';
import 'package:nba_book_catalogue/providers/classifications_provider.dart';
import 'package:nba_book_catalogue/providers/text_contoller.dart';

class EditClassificationsScreen extends ConsumerWidget {
  const EditClassificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classificationsAsync = ref.watch(classificationsProvider);
    final typeEditor = ref.watch(typeEditorProvider);

    return classificationsAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, st) => Scaffold(
            appBar: AppBar(title: const Text('Edit Classifications')),
            body: Center(child: Text('Error loading classifications: $e')),
          ),
      data: (classifications) {
        final items = {for (var c in classifications) c.id: c.name};

        return ManageTypesPage(
          title: 'Classifications',
          inputLabel: 'Enter classification',
          items: items,
          onItemAdded: () async {
            final text = typeEditor.descriptionText.trim();
            if (text.isEmpty) return;
            await ref
                .read(classificationsProvider.notifier)
                .addClassification(text);
            typeEditor.clear();
          },
          onItemUpdated: () async {
            final text = typeEditor.descriptionText.trim();
            final id = typeEditor.selectedId;
            if (id == null || text.isEmpty) return;
            await ref
                .read(classificationsProvider.notifier)
                .updateClassification(id, text);
            typeEditor.clear();
          },
          onItemDeleted: (id) async {
            await ref
                .read(classificationsProvider.notifier)
                .deleteClassification(id, context);
          },
        );
      },
    );
  }
}
