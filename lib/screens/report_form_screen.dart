import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/student_report.dart';
import '../services/report_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// The asynchronous UI responses of the Student Portal report screen.
///
/// Activity 9 requires the four essential responses: Loading, Success,
/// Empty and Error. `idle` is the normal state of the form before any
/// request is made.
enum ReportUiState {
  /// The form is waiting for the student to type.
  idle,

  /// A request is pending - a progress indicator is shown.
  loading,

  /// The request finished successfully.
  success,

  /// The request finished successfully but there is no record to show.
  empty,

  /// The request failed - an explanation and a Retry action are shown.
  error,
}

/// Which part of the screen is currently visible.
enum ReportPanel {
  /// The report form with its input fields.
  form,

  /// The list of the reports that were already submitted.
  list,
}

/// Report Form screen of the Student Portal (new in Activity 9).
///
/// The screen shows the report form of the group's approved system and it
/// demonstrates the four asynchronous UI responses - Loading, Success, Empty
/// and Error - using the shared widgets from `lib/widgets/`.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  /// Key of the [Form] used for the field-level validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  /// SIMULATED service - the REST API is not implemented yet.
  final ReportService _service = ReportService();

  String _category = AppConstants.reportCategories.first;
  String _priority = 'Medium';

  /// Activity 9 demo switch that turns a valid submission into an error.
  bool _simulateFailure = false;

  ReportUiState _uiState = ReportUiState.idle;
  ReportPanel _panel = ReportPanel.form;

  String? _errorMessage;
  StudentReport? _submittedReport;
  List<StudentReport> _reports = <StudentReport>[];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Reports that match the text typed in the list filter.
  List<StudentReport> get _visibleReports {
    final String query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return _reports;
    }

    return _reports.where((StudentReport report) {
      return report.title.toLowerCase().contains(query) ||
          report.category.toLowerCase().contains(query) ||
          report.location.toLowerCase().contains(query) ||
          report.description.toLowerCase().contains(query);
    }).toList();
  }

  /// Validates the form and runs the simulated submission.
  Future<void> _submitReport() async {
    FocusScope.of(context).unfocus();

    final FormState? formState = _formKey.currentState;

    // The [Form] is only mounted while the form panel is on screen. When the
    // Error response is shown the values were already validated, so the
    // Retry action goes straight to the request.
    if (formState != null && !formState.validate()) {
      // The field-level messages are already visible under every invalid
      // input, this message only summarises the problem.
      setState(() {
        _errorMessage = 'Please correct the highlighted fields.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _uiState = ReportUiState.loading;
    });

    final StudentReport report = StudentReport(
      title: _titleController.text.trim(),
      category: _category,
      location: _locationController.text.trim(),
      priority: _priority,
      description: _descriptionController.text.trim(),
      submittedAt: DateTime.now(),
    );

    try {
      final StudentReport saved =
          await _service.submitReport(report, simulateFailure: _simulateFailure);

      if (!mounted) {
        return;
      }

      setState(() {
        _submittedReport = saved;
        _uiState = ReportUiState.success;
      });
    } on ReportServiceException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _uiState = ReportUiState.error;
      });
    }
  }

  /// Loads the submitted reports - this is where the Empty response
  /// appears while no report has been created yet.
  Future<void> _openReports() async {
    setState(() {
      _panel = ReportPanel.list;
      _uiState = ReportUiState.loading;
      _errorMessage = null;
    });

    try {
      final List<StudentReport> reports = await _service.fetchReports();

      if (!mounted) {
        return;
      }

      setState(() {
        _reports = reports;
        _uiState = reports.isEmpty ? ReportUiState.empty : ReportUiState.success;
      });
    } on ReportServiceException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _uiState = ReportUiState.error;
      });
    }
  }

  /// Goes back to the form and clears the response panels.
  void _backToForm() {
    setState(() {
      _panel = ReportPanel.form;
      _uiState = ReportUiState.idle;
      _errorMessage = null;
    });
  }

  /// Repeats the request that failed.
  Future<void> _retry() async {
    if (_panel == ReportPanel.list) {
      await _openReports();
      return;
    }

    await _submitReport();
  }

  /// Clears the form after a successful submission.
  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();
    setState(() {
      _category = AppConstants.reportCategories.first;
      _priority = 'Medium';
      _submittedReport = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isFormPanel = _panel == ReportPanel.form;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFormPanel ? 'Student Report Form' : 'Student Reports'),
        actions: <Widget>[
          TextButton(
            onPressed: _uiState == ReportUiState.loading
                ? null
                : (isFormPanel ? _openReports : _backToForm),
            child: Text(isFormPanel ? 'View Reports' : 'New Report'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildPanel(),
          ),
        ),
      ),
    );
  }

  /// Builds the panel that matches the current response.
  Widget _buildPanel() {
    if (_panel == ReportPanel.list) {
      switch (_uiState) {
        case ReportUiState.loading:
          return _buildLoading('Loading your reports...');
        case ReportUiState.error:
          return _buildError();
        case ReportUiState.empty:
        case ReportUiState.success:
        case ReportUiState.idle:
          return _buildReportList();
      }
    }

    switch (_uiState) {
      case ReportUiState.loading:
        // The form stays on screen while the request is pending, the submit
        // action is disabled so a report cannot be submitted twice.
        return _buildForm();
      case ReportUiState.error:
        return _buildError();
      case ReportUiState.success:
        return _buildSuccess();
      case ReportUiState.empty:
      case ReportUiState.idle:
        return _buildForm();
    }
  }

  /// LOADING response - a progress indicator is shown and the submit
  /// action is disabled so a report cannot be submitted twice.
  Widget _buildLoading(String message) {
    return Column(
      key: const ValueKey<String>('loading'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'The submit button stays disabled while the request is pending.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// SUCCESS response - the saved report and the next actions.
  Widget _buildSuccess() {
    final StudentReport? report = _submittedReport;

    return Column(
      key: const ValueKey<String>('success'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 76,
        ),
        const SizedBox(height: 12),
        const Text(
          'Report submitted successfully!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'The Student Portal team has received your report.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (report != null) _buildReportCard(report),
        const SizedBox(height: 20),
        AppButton(
          text: 'Submit Another Report',
          icon: Icons.add,
          onPressed: () {
            _resetForm();
            _backToForm();
          },
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'View All Reports',
          icon: Icons.list_alt,
          isOutlined: true,
          onPressed: _openReports,
        ),
        const SizedBox(height: 16),
        const Text(
          'Simulated response - no real database record was created.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  /// EMPTY response - there is no report record to show.
  Widget _buildEmpty() {
    final bool filtered = _reports.isNotEmpty;

    return Column(
      key: const ValueKey<String>('empty'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.inbox_outlined,
          color: Colors.blueGrey,
          size: 76,
        ),
        const SizedBox(height: 16),
        Text(
          filtered
              ? 'No reports match your search.'
              : 'No reports available yet.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          filtered
              ? 'Try another keyword or clear the filter to see all reports.'
              : 'Submitted reports will appear here once you create one.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (filtered)
          AppButton(
            text: 'Clear Search',
            icon: Icons.clear,
            isOutlined: true,
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
          )
        else
          AppButton(
            text: 'Create Your First Report',
            icon: Icons.assignment_outlined,
            onPressed: () {
              _resetForm();
              _backToForm();
            },
          ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Refresh Reports',
          icon: Icons.refresh,
          isOutlined: true,
          onPressed: _openReports,
        ),
      ],
    );
  }

  /// ERROR response - a clear explanation plus a Retry action.
  Widget _buildError() {
    return Column(
      key: const ValueKey<String>('error'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 76,
        ),
        const SizedBox(height: 16),
        const Text(
          'Submission failed',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ??
              'The request could not be completed. Please try again.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'This is a simulated failure used for the Activity 9 demonstration.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Retry',
          icon: Icons.refresh,
          onPressed: _retry,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Edit Report',
          icon: Icons.edit_outlined,
          isOutlined: true,
          onPressed: _backToForm,
        ),
      ],
    );
  }

  /// The list panel with the filter field and the submitted reports.
  Widget _buildReportList() {
    final List<StudentReport> visible = _visibleReports;

    if (visible.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      key: const ValueKey<String>('list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Submitted Reports',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${visible.length} report(s) found',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Filter reports',
          hintText: 'Search by title, category or location',
          controller: _searchController,
          prefixIcon: Icons.search,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: ListView.builder(
            itemCount: visible.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildReportCard(visible[index]);
            },
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'Create New Report',
          icon: Icons.add,
          onPressed: () {
            _resetForm();
            _backToForm();
          },
        ),
      ],
    );
  }

  /// A single report shown as a card.
  Widget _buildReportCard(StudentReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(report.title),
        subtitle: Text(
          '${report.category} | ${report.priority} priority\n'
          '${report.location}\n'
          '${report.description}',
        ),
        isThreeLine: true,
      ),
    );
  }

  /// The report form with the field-level validation.
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Submit a Student Report',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Report academic, enrollment, account or campus facility '
              'concerns to the Student Portal team.',
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Report Title *',
              hintText: 'e.g. Subject grade not reflected in the portal',
              controller: _titleController,
              prefixIcon: Icons.title,
              validator: (String? value) {
                final String text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Report title is required.';
                }
                if (text.length < AppConstants.titleMinLength) {
                  return 'Report title must be at least '
                      '${AppConstants.titleMinLength} characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<String>>[
                for (final String category in AppConstants.reportCategories)
                  DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _category = value ?? _category;
                });
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Location *',
              hintText: 'e.g. Main Campus - Library',
              controller: _locationController,
              prefixIcon: Icons.location_on_outlined,
              validator: (String? value) {
                if ((value?.trim() ?? '').isEmpty) {
                  return 'Location is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority *',
                border: OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<String>>[
                for (final String priority in AppConstants.reportPriorities)
                  DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _priority = value ?? _priority;
                });
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description *',
              hintText: 'Describe the issue in at least '
                  '${AppConstants.descriptionMinLength} characters',
              controller: _descriptionController,
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              maxLength: 500,
              validator: (String? value) {
                final String text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Description is required.';
                }
                if (text.length < AppConstants.descriptionMinLength) {
                  return 'Description must be at least '
                      '${AppConstants.descriptionMinLength} characters.';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Simulate a server error (demo only)'),
              subtitle: const Text(
                'Activity 9 switch - turns a valid submission into the '
                'Error response so the Retry action can be demonstrated.',
              ),
              value: _simulateFailure,
              onChanged: (bool value) {
                setState(() {
                  _simulateFailure = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_uiState == ReportUiState.loading) ...<Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: const Row(
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Submitting your report... please wait.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            AppButton(
              text: 'Submit Report',
              icon: Icons.send,
              isLoading: _uiState == ReportUiState.loading,
              onPressed: _uiState == ReportUiState.loading
                  ? null
                  : () {
                      _submitReport();
                    },
            ),
            const SizedBox(height: 12),
            const Text(
              'Simulated submission - the report is kept in memory only, '
              'no real database record is created.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
