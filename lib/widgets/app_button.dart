import 'package:flutter/material.dart';

/// Shared action button for the Student Portal.
///
/// The same widget is reused by the Home screen and by the Report Form
/// screen so that every action in the app looks and behaves the same way.
///
/// * [onPressed] is `null` (or [isLoading] is true) while an action cannot
///   be performed - the button is then rendered in its disabled state, which
///   is how the Report Form prevents duplicate submissions.
/// * [isLoading] shows a progress indicator inside the button.
class AppButton extends StatelessWidget {
  /// Label shown on the button.
  final String text;

  /// Action executed when the button is pressed. `null` disables the button.
  final VoidCallback? onPressed;

  /// Shows a spinner inside the button and disables it.
  final bool isLoading;

  /// Renders an outlined button instead of a filled one.
  final bool isOutlined;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional background / foreground colour override.
  final Color? color;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    final Widget label = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(text),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18),
                const SizedBox(width: 10),
              ],
              Text(text),
            ],
          );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        child: label,
      );
    }

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: label,
    );
  }
}
