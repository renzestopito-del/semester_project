import '../models/student_report.dart';

/// Thrown when a simulated request cannot be completed.
class ReportServiceException implements Exception {
  /// Human readable explanation shown to the user.
  final String message;

  const ReportServiceException(this.message);

  @override
  String toString() => 'ReportServiceException: $message';
}

/// SIMULATED data service for the Student Portal (Activity 9).
///
/// The REST API and PostgreSQL backend are not implemented yet, so every
/// method below returns a *simulated* asynchronous result. The delay is what
/// makes the Loading, Success, Empty and Error UI responses observable.
class ReportService {
  /// How long a simulated request takes before it answers.
  static const Duration simulatedLatency = Duration(seconds: 3);

  /// In-memory store used instead of a real database.
  static final List<StudentReport> _simulatedStore = <StudentReport>[];

  /// Fetches the reports that were already submitted.
  ///
  /// The result is empty while no report has been created yet, which is how
  /// the Empty UI response is produced.
  Future<List<StudentReport>> fetchReports() async {
    await Future<void>.delayed(simulatedLatency);

    return List<StudentReport>.unmodifiable(_simulatedStore);
  }

  /// Submits a new report.
  ///
  /// When [simulateFailure] is true the request fails on purpose so that the
  /// Error UI response (and the Retry action) can be demonstrated.
  Future<StudentReport> submitReport(
    StudentReport report, {
    bool simulateFailure = false,
  }) async {
    await Future<void>.delayed(simulatedLatency);

    if (simulateFailure) {
      throw const ReportServiceException(
        'The simulated request failed. The report was not saved.',
      );
    }

    _simulatedStore.add(report);

    return report;
  }

  /// Removes every simulated record. Used when a demo is restarted.
  void clear() {
    _simulatedStore.clear();
  }
}
