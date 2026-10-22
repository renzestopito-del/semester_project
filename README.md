# Demo

## Summary

This project aims to address a community problem through a Flutter Web application. Its initial features include a Home page and a Login page, with plans to integrate a REST API and PostgreSQL database.

**Activity 9** continues the same project and repository: it adds the Report
Form screen (`lib/screens/report_form_screen.dart`), reuses the shared
`AppButton` and `AppTextField` widgets, and demonstrates the four essential
asynchronous UI responses - Loading, Success, Empty and Error.

## Current stack

Flutter Web / Dart; planned REST API and PostgreSQL. All asynchronous responses
used in Activity 9 are **simulated** with `Future.delayed`, no database record
is created.

## Folder structure

```
lib/
  main.dart
  app.dart
  screens/
    home_screen.dart
    login_screen.dart
    report_form_screen.dart   <- new in Activity 9
  widgets/
    app_button.dart
    app_text_field.dart
  services/
    report_service.dart       <- simulated data service
    api_service.dart          <- from Activity 8
  models/
    student_report.dart
  routes/
    app_routes.dart
  constants/
    app_constants.dart
```

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

## How to reproduce the four UI responses

| Response  | What to do                                                                    |
| --------- | ----------------------------------------------------------------------------- |
| LOADING   | Fill the form and press **Submit Report** (the request takes 3 seconds).      |
| SUCCESS   | Let the request finish - the confirmation and the saved report are shown.     |
| EMPTY     | Press **View Reports** before creating a report, or filter to no match.      |
| ERROR     | Turn on **Simulate a server error (demo only)** and submit a valid form.     |

After an error the screen offers **Retry** (repeats the request) and
**Edit Report** (returns to the filled form). Turn the switch off before
pressing **Retry** to see the request succeed.

## Screenshots (Activity 9)

All screenshots are in `screenshots/activity9/`.

| # | File                              | What it shows                                                       |
| - | --------------------------------- | ------------------------------------------------------------------- |
| 1 | `screenshot1_project_structure.png` | VS Code Explorer with the Activity 8 files and the new `lib/screens/report_form_screen.dart`. |
| 2 | `screenshot2_widget_reuse.png`      | `AppTextField` / `AppButton` used in `report_form_screen.dart` (left) and `AppButton` used again in `home_screen.dart` (right). |
| 3 | `screenshot3_loading_state.png`     | **LOADING** - spinner banner and the disabled *Submit Report* button. |
| 4 | `screenshot4_success_state.png`     | **SUCCESS** - confirmation and the saved report.                     |
| 5 | `screenshot5_empty_state.png`       | **EMPTY** - no report exists yet, with the first-report action.      |
| 6 | `screenshot6_error_state.png`       | **ERROR** - error message plus the *Retry* and *Edit Report* actions. |
| 7 | `screenshot7_field_validation.png`   | **VALIDATION** - required-field messages under the empty inputs; the request is not sent. |

## Evidence report (Activity 9)

| File                                        | What it contains                                                                      |
| ------------------------------------------- | ------------------------------------------------------------------------------------- |
| `docs/Activity9_Student_Portal_Report.docx` | Word evidence report: summary, GitHub link, verification checklist, screenshots, reflection. |
| `docs/Activity9_Student_Portal_Report.pdf`  | The same report as PDF.                                                                 |
| `docs/activity9_report.html`                | The source of the report (used to print the PDF).                                       |

## First checkpoint

Date: October 15, 2026 | Commit: `f1dccad` - Initial Flutter Web project

## Second checkpoint (Activity 9)

Date: October 22, 2026 | Commit: `REPLACE_ACT9_COMMIT` - Add report form screen with loading, success, empty and error states

Repository: https://github.com/renzestopito-del/semester_project
