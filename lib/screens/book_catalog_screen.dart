import 'package:nba_book_catalogue/components/buttons/custom_button.dart';
import 'package:nba_book_catalogue/components/build_table.dart';
import 'package:nba_book_catalogue/components/buttons/export_button.dart';
import 'package:nba_book_catalogue/components/buttons/import_button.dart';
import 'package:nba_book_catalogue/components/search_field.dart';
import 'package:nba_book_catalogue/data_sources/book_data_source.dart';
import 'package:nba_book_catalogue/providers/book_provider.dart';
import 'package:nba_book_catalogue/providers/classifications_provider.dart';
import 'package:nba_book_catalogue/providers/subject_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nba_book_catalogue/screens/edit_classification_screen.dart';
import 'package:nba_book_catalogue/screens/edit_subjects_screen.dart';
import 'package:nba_book_catalogue/services/import_excel.dart';
import 'package:nba_book_catalogue/utils/modals/show_book_modal.dart';
import 'package:nba_book_catalogue/utils/screen_helper.dart';

class BookCatalogPage extends ConsumerStatefulWidget {
  const BookCatalogPage({super.key});

  @override
  ConsumerState<BookCatalogPage> createState() => _BookCatalogPageState();
}

class _BookCatalogPageState extends ConsumerState<BookCatalogPage> {
  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final classifications =
        ref.watch(classificationsProvider).asData?.value ?? [];
    final subjects = ref.watch(subjectsProvider).asData?.value ?? [];
    final query = ref.watch(bookSearchQueryProvider).trim().toLowerCase();
    final classificationMap = {for (var c in classifications) c.id: c.name};
    final subjectMap = {for (var s in subjects) s.id: s.name};
    final isEditing = ref.watch(isEditingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Catalog'),
        centerTitle: true,
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.category),
            tooltip: 'Edit Classifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditClassificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.topic_outlined),
            tooltip: 'Edit Subjects',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditSubjectsScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              color: Colors.amber,
              icon: Icon(isEditing ? Icons.lock_open : Icons.lock),
              tooltip: isEditing ? 'Disable Editing' : 'Enable Editing',
              onPressed: () {
                ref.read(isEditingProvider.notifier).state = !isEditing;
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flex(
              direction:
                  ScreenHelper.isTablet(context)
                      ? Axis.vertical
                      : Axis.horizontal,
              mainAxisAlignment:
                  ScreenHelper.isTablet(context)
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                ReusableTextField(
                  onChanged: (value) {
                    ref.read(bookSearchQueryProvider.notifier).state =
                        value.trim().toLowerCase();
                  },
                ),
                SizedBox(height: 10),
                // Buttons section
                Wrap(
                  spacing: 10,
                  runSpacing: 10,

                  children: [
                    ReusableActionButton(
                      label: 'Add Book',
                      onPressed: () => showAddBookModal(context),
                    ),
                    ImportButton(),
                    ExportButton(),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            booksAsync.when(
              data: (books) {
                if (classificationMap.isEmpty || subjectMap.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredBooks =
                    books.where((book) {
                      final publicationYearStr =
                          book.publicationDate.toString();
                      return book.title.toLowerCase().contains(query) ||
                          book.author.toLowerCase().contains(query) ||
                          publicationYearStr.contains(query) ||
                          book.publisher.toLowerCase().contains(query) ||
                          book.isbn.toLowerCase().contains(query) ||
                          classificationMap[book.classificationId]
                                  ?.toLowerCase()
                                  .contains(query) ==
                              true ||
                          subjectMap[book.subjectId]?.toLowerCase().contains(
                                query,
                              ) ==
                              true;
                    }).toList();

                final dataSource = BookDataSource(
                  filteredBooks,
                  context,
                  classificationMap: classificationMap,
                  subjectMap: subjectMap,
                  query: query,
                );

                return Expanded(
                  child: BuildTable(
                    dataSource: dataSource,
                    isEditing: isEditing,
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),

              error: (e, st) {
                final isNetworkError =
                    e.toString().contains('SocketException') ||
                    e.toString().toLowerCase().contains('network');

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isNetworkError ? Icons.wifi_off : Icons.error_outline,
                        color:
                            isNetworkError ? Colors.orange : Colors.redAccent,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isNetworkError
                            ? 'No internet connection. Please check your connection.'
                            : 'Failed to load data. pls check your connection and try again.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          return ref.invalidate(booksProvider);
                        },
                        label: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (kDebugMode)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            e.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
