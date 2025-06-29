import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? errorText;
  final IconData? icon;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;

  final Function(String)? onSubmitted;

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const CustomTextField({
    super.key,

    this.errorText,
    this.validator,
    required this.label,
    required this.icon,
    required this.controller,
    this.onSubmitted,
    this.focusNode,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: autovalidateMode,
      controller: controller,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      validator: validator,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        errorText: errorText,
        border: OutlineInputBorder(
          borderSide: const BorderSide(width: 0, color: Colors.transparent),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: Colors.green),
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(icon, color: Colors.black, size: 20),

        labelText: label,
        labelStyle: TextStyle(color: Colors.black, fontSize: 12),
      ),

      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}
