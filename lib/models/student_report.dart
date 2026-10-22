/// Data model for a report submitted through the Student Portal.
class StudentReport {
  /// Short title given by the student.
  final String title;

  /// Category of the report (see `AppConstants.reportCategories`).
  final String category;

  /// Where the issue was observed, e.g. "Main Campus - Library".
  final String location;

  /// Priority chosen by the student.
  final String priority;

  /// Full description of the issue.
  final String description;

  /// When the report was submitted.
  final DateTime submittedAt;

  const StudentReport({
    required this.title,
    required this.category,
    required this.location,
    required this.priority,
    required this.description,
    required this.submittedAt,
  });

  /// Returns a copy of this report with the given fields replaced.
  StudentReport copyWith({
    String? title,
    String? category,
    String? location,
    String? priority,
    String? description,
    DateTime? submittedAt,
  }) {
    return StudentReport(
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  @override
  String toString() {
    return 'StudentReport(title: $title, category: $category, '
        'location: $location, priority: $priority)';
  }
}
