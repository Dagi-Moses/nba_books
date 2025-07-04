import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nba_book_catalogue/components/buttons/custom_button.dart';
import 'package:nba_book_catalogue/components/custom_list_tile.dart';
import 'package:nba_book_catalogue/components/delete_confirmation.dart';
import 'package:nba_book_catalogue/components/search_field.dart';
import 'package:nba_book_catalogue/providers/text_contoller.dart';

class ManageTypesPage extends ConsumerWidget {
  final String title;
  final String inputLabel;
  final VoidCallback onItemAdded;
  final VoidCallback onItemUpdated;
  final Future<void> Function(int id) onItemDeleted;
  final Map<int, String> items;

  const ManageTypesPage({
    Key? key,
    required this.title,
    required this.inputLabel,
    required this.onItemAdded,
    required this.onItemUpdated,
    required this.onItemDeleted,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textControllerNotifier = ref.watch(typeEditorProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Manage $title",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      //flex: 3,
                      child: ReusableTextField(
                        hintText: inputLabel,
                        controller:
                            textControllerNotifier.descriptionController,
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable:
                          textControllerNotifier.descriptionController,
                      builder: (context, value, child) {
                        final showButtons =
                            value.text.isNotEmpty ||
                            textControllerNotifier.selectedId != null;
                        return Visibility(
                          visible: showButtons,

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ReusableActionButton(
                                label:
                                    textControllerNotifier.selectedId == null
                                        ? 'Add'
                                        : 'Update',
                                onPressed: () {
                                  if (textControllerNotifier.selectedId ==
                                      null) {
                                    onItemAdded();
                                  } else {
                                    onItemUpdated();
                                    textControllerNotifier.selectedId = null;
                                    textControllerNotifier.descriptionController
                                        .clear();
                                  }
                                },
                                backgroundColor: Colors.green,
                              ),
                              Visibility(
                                visible:
                                    textControllerNotifier.selectedId != null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ReusableActionButton(
                                    label: 'Cancel',
                                    onPressed: () {
                                      textControllerNotifier.selectedId = null;
                                      textControllerNotifier
                                          .descriptionController
                                          .clear();
                                    },
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Existing $title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    // color: punchRed,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(right: 50),
                    shrinkWrap: true,
                    //  physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      int typeId = items.keys.elementAt(index);
                      String description = items[typeId]!;

                      return CustomListItem(
                        title: description,
                        onEdit: () {
                          textControllerNotifier.selectedId = typeId;
                          textControllerNotifier.descriptionController.text =
                              description;
                        },
                        onDelete: () async {
                          deleteItemDialog(context, description, () async {
                            await onItemDeleted(typeId);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
