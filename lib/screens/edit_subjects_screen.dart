import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nba_book_catalogue/components/manage_types.dart';
import 'package:nba_book_catalogue/providers/classifications_provider.dart';
import 'package:nba_book_catalogue/providers/subject_provider.dart';
import 'package:nba_book_catalogue/providers/text_contoller.dart';

class EditSubjectsScreen extends ConsumerWidget {
  const EditSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classificationsAsync = ref.watch(subjectsProvider);
    final typeEditor = ref.watch(typeEditorProvider);

    return classificationsAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, st) => Scaffold(
            appBar: AppBar(title: const Text('Edit Subject')),
            body: Center(child: Text('Error loading Subjects: $e')),
          ),
      data: (classifications) {
        final items = {for (var c in classifications) c.id: c.name};

        return ManageTypesPage(
          title: 'Subjects',
          inputLabel: 'Enter Subject',
          items: items,
          onItemAdded: () async {
            final text = typeEditor.descriptionText.trim();
            if (text.isEmpty) return;
            await ref
                .read(classificationsProvider.notifier)
                .addClassification(text);
            typeEditor.clear();
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Subject added')));
            }
          },
          onItemUpdated: () async {
            final text = typeEditor.descriptionText.trim();
            final id = typeEditor.selectedId;
            if (id == null || text.isEmpty) return;
            await ref
                .read(classificationsProvider.notifier)
                .updateClassification(id, text);
            typeEditor.clear();
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Subject updated')));
            }
          },
          onItemDeleted: (id) async {
            await ref
                .read(classificationsProvider.notifier)
                .deleteClassification(id);
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Subject deleted')));
            }
          },
        );
      },
    );
  }
}
