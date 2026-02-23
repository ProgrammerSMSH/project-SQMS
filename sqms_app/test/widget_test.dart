import 'package:flutter_test/flutter_test.dart';
import 'package:sqms_app/main.dart';
import 'package:sqms_app/constants.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SQMSApp());

    // Verify that onboarding title is present.
    expect(find.text(AppStrings.onboardingTitle), findsOneWidget);
    
    // Verify that the Get Started button is present.
    expect(find.text('Get Started'), findsOneWidget);
  });
}
