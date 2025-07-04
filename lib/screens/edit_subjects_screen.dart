import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nba_book_catalogue/components/manage_types.dart';
import 'package:nba_book_catalogue/providers/subject_provider.dart';
import 'package:nba_book_catalogue/providers/text_contoller.dart';

class EditSubjectsScreen extends ConsumerWidget {
  const EditSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final typeEditor = ref.watch(typeEditorProvider);

    return subjectsAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, st) => Scaffold(
            appBar: AppBar(title: const Text('Edit Subject')),
            body: Center(child: Text('Error loading Subjects: $e')),
          ),
      data: (subjects) {
        final items = {for (var c in subjects) c.id: c.name};

        return ManageTypesPage(
          title: 'Subjects',
          inputLabel: 'Enter Subject',
          items: items,
          onItemAdded: () async {
            final text = typeEditor.descriptionText.trim();
            if (text.isEmpty) return;
            await ref.read(subjectsProvider.notifier).addSubject(text);
            typeEditor.clear();
          },
          onItemUpdated: () async {
            final text = typeEditor.descriptionText.trim();
            final id = typeEditor.selectedId;
            if (id == null || text.isEmpty) return;
            await ref.read(subjectsProvider.notifier).updateSubject(id, text);
            typeEditor.clear();
          },
          onItemDeleted: (id) async {
            await ref
                .read(subjectsProvider.notifier)
                .deleteSubject(id, context);
          },
        );
      },
    );
  }
}
