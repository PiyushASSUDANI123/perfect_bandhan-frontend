import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:your_project_name/main.dart';
import 'package:your_project_name/providers/auth_provider.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MyApp(),
      ),
    );

    // Verify that our branding header is displayed.
    expect(find.text('SINDHI SHADI'), findsOneWidget);
    expect(find.text('COMMUNITY MATRIMONY'), findsOneWidget);

    // Verify that we have the login mode tabs
    expect(find.text('OTP LOGIN'), findsOneWidget);
    expect(find.text('PASSWORD LOGIN'), findsOneWidget);

    // Verify that we have phone text input hint.
    expect(find.text('Enter your 10-digit number'), findsOneWidget);
  });
}
