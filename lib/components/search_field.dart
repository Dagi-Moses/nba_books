import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReusableTextField extends StatelessWidget {
  final void Function(String)? onChanged;
  final String hintText;
  final double maxWidth;
  final TextEditingController? controller;
  final TextInputAction textInputAction;

  const ReusableTextField({
    super.key,
    this.onChanged,
    this.hintText = 'Search',
    this.maxWidth = 700,
    this.controller,
    this.textInputAction = TextInputAction.search,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        textInputAction: textInputAction,
      ),
    );
  }
}
