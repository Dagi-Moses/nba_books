import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TypeEditorNotifier extends ChangeNotifier {
  final TextEditingController descriptionController = TextEditingController();
  int? selectedId;

  String get descriptionText => descriptionController.text;

  void clear() {
    selectedId = null;
    descriptionController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}

final typeEditorProvider = ChangeNotifierProvider<TypeEditorNotifier>((ref) {
  return TypeEditorNotifier();
});
