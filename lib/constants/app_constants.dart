/// Shared constants for the Student Portal application.
///
/// Keeping the strings in one place means every screen shows the same
/// system identity (the name of the group's approved project).
class AppConstants {
  const AppConstants._();

  /// Name of the group's approved system.
  static const String appTitle = 'Student Portal';

  /// Short description shown on the Home screen.
  static const String appTagline =
      'A web-based student portal for academic updates, report requests '
      'and account access.';

  /// Categories a student can report, taken from the approved system.
  static const List<String> reportCategories = <String>[
    'Academic Performance',
    'Enrollment & Scheduling',
    'Account & Login',
    'Campus Facility',
  ];

  /// Priority levels available on the report form.
  static const List<String> reportPriorities = <String>[
    'Low',
    'Medium',
    'High',
  ];

  /// Minimum number of characters accepted for the report title.
  static const int titleMinLength = 5;

  /// Minimum number of characters accepted for the report description.
  static const int descriptionMinLength = 20;
}
