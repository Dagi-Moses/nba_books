import 'package:nba_book_catalogue/components/custom_text_field.dart';
import 'package:nba_book_catalogue/models/classification_model.dart';
import 'package:nba_book_catalogue/models/subject.dart' show Subject;
import 'package:nba_book_catalogue/providers/book_provider.dart';
import 'package:nba_book_catalogue/providers/classifications_provider.dart';
import 'package:nba_book_catalogue/providers/subject_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBookModal extends ConsumerStatefulWidget {
  const AddBookModal({super.key});

  @override
  ConsumerState<AddBookModal> createState() => _AddBookModalState();
}

class _AddBookModalState extends ConsumerState<AddBookModal> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  DateTime? _selectedDate;

  int? _selectedClassificationId;
  int? _selectedSubjectId;

  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('books').insert({
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'publisher': _publisherController.text.trim(),
        'publication_date':
            _selectedDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'classification_id': _selectedClassificationId,
        'subject_id': _selectedSubjectId,
      });
      ref.invalidate(booksProvider);

      _titleController.clear();
      _authorController.clear();
      _publisherController.clear();
      setState(() {
        _selectedDate = null;
        _selectedClassificationId = null;
        _selectedSubjectId = null;
      });
      Fluttertoast.showToast(
        msg: "Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print("error: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to add book: $e'),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  final _titleFocus = FocusNode();
  final _authorFocus = FocusNode();
  final _publisherFocus = FocusNode();
  @override
  void initState() {
    _titleFocus.requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _authorFocus.dispose();
    _publisherFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classificationAsync = ref.watch(classificationsProvider);
    final subjectAsync = ref.watch(subjectsProvider);

    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New Book',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Title',
                controller: _titleController,
                icon: Icons.menu_book,
                focusNode: _titleFocus,
                onSubmitted:
                    (_) => FocusScope.of(context).requestFocus(_authorFocus),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Author',
                controller: _authorController,
                icon: Icons.person_outline,
                focusNode: _authorFocus,
                onSubmitted:
                    (_) => FocusScope.of(context).requestFocus(_publisherFocus),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Publisher',
                controller: _publisherController,
                icon: Icons.business_outlined,
                focusNode: _publisherFocus,

                validator:
                    (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Publication Date',
                      controller: TextEditingController(
                        text:
                            _selectedDate == null
                                ? ''
                                : DateFormat.yMMMd().format(_selectedDate!),
                      ),
                      icon: Icons.date_range,
                      validator:
                          (val) =>
                              _selectedDate == null ? 'Select a date' : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              classificationAsync.when(
                data:
                    (classifications) => _dropdownField<Classification>(
                      label: 'Classification',
                      icon: Icons.category_outlined,
                      value:
                          classifications
                                  .where(
                                    (s) => s.id == _selectedClassificationId,
                                  )
                                  .isNotEmpty
                              ? classifications.firstWhere(
                                (s) => s.id == _selectedClassificationId,
                              )
                              : null,
                      items: classifications,
                      getLabel: (c) => c.name,
                      getId: (c) => c.id,
                      onChanged: (val) {
                        setState(() => _selectedClassificationId = val?.id);
                      },
                    ),
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Error: $e'),
              ),

              const SizedBox(height: 12),

              subjectAsync.when(
                data:
                    (subjects) => _dropdownField<Subject>(
                      label: 'Subject',
                      icon: Icons.topic_outlined,
                      value:
                          subjects
                                  .where((s) => s.id == _selectedSubjectId)
                                  .isNotEmpty
                              ? subjects.firstWhere(
                                (s) => s.id == _selectedSubjectId,
                              )
                              : null,
                      items: subjects,
                      getLabel: (s) => s.name,
                      getId: (s) => s.id,
                      onChanged: (val) {
                        setState(() => _selectedSubjectId = val?.id);
                      },
                    ),
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Error: $e'),
              ),
              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: const Icon(Icons.save, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  label:
                      _loading
                          ? SizedBox(
                            height: 20,
                            width: 20,

                            child: const CircularProgressIndicator(),
                          )
                          : const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _dropdownField<T>({
  required String label,
  required IconData icon,
  required T? value,
  required List<T> items,
  required void Function(T?) onChanged,
  required String Function(T) getLabel,
  required int Function(T) getId,
  FocusNode? focusNode,
}) {
  return DropdownButtonFormField<T>(
    value: value,
    focusNode: focusNode,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      isDense: true,
    ),
    items:
        items
            .map(
              (item) =>
                  DropdownMenuItem<T>(value: item, child: Text(getLabel(item))),
            )
            .toList(),
    onChanged: onChanged,
    validator: (val) => val == null ? 'Select $label' : null,
  );
}
