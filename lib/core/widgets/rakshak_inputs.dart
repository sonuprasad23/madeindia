import 'package:flutter/material.dart';

/// Standard text field with a consistent label/helper/error contract.
class RakshakTextField extends StatelessWidget {
  const RakshakTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.suffixIcon,
    this.prefixText,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? prefixText;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      maxLength: maxLength,
      onChanged: onChanged,
      enabled: enabled,
      autofocus: autofocus,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: errorText == null ? helperText : null,
        errorText: errorText,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
      ),
    );
  }
}

/// Standard dropdown/select field.
class RakshakDropdown<T> extends StatelessWidget {
  const RakshakDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, errorText: errorText),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
