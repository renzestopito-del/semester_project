// Basic Flutter widget test for the Student Portal.

import 'package:flutter_test/flutter_test.dart';

import 'package:semester_project/app.dart';

void main() {
  testWidgets('Home screen shows the Student Portal navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SemesterProjectApp());

    // The Home screen (Activity 8) keeps its navigation and now also offers
    // the Report Form action added in Activity 9.
    expect(find.text('Open Login'), findsOneWidget);
    expect(find.text('Open Student Report Form'), findsOneWidget);
  });
}
