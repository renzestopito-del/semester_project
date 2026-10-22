import 'package:flutter/material.dart';

/// Shared input field for the Student Portal.
///
/// The widget is a [TextFormField] so it can be used inside a `Form` and
/// show field-level validation messages. It is reused by the Report Form
/// screen and by the report list filter.
class AppTextField extends StatelessWidget {
  /// Label shown above the input.
  final String label;

  /// Controller holding the current value of the input.
  final TextEditingController? controller;

  /// Hides the typed characters (used for passwords).
  final bool obscureText;

  /// Placeholder shown while the field is empty.
  final String? hintText;

  /// Small helper text shown under the input.
  final String? helperText;

  /// Field-level validation callback. Returning a non-null string marks the
  /// field as invalid and displays the returned message.
  final String? Function(String?)? validator;

  /// Keyboard type used on the on-screen keyboard.
  final TextInputType? keyboardType;

  /// Number of lines shown. Use more than one for long inputs.
  final int maxLines;

  /// Optional leading icon.
  final IconData? prefixIcon;

  /// Maximum number of characters accepted.
  final int? maxLength;

  /// Called every time the value of the input changes.
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.hintText,
    this.helperText,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(),
      ),
    );
  }
}
