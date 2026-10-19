import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_monitoring_app/core/auth.dart';
import 'package:med_monitoring_app/main.dart';

void main() {
  void phoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('wrong password shows an error and stays on login', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.textContaining("don't match"), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('demo account signs in and shows the home screen', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Elena'), findsOneWidget);
    expect(find.text('Vitals Today'), findsOneWidget);
    expect(find.text('2 of 4 done'), findsOneWidget);
  });

  testWidgets('forgot password flow sets a new password', (tester) async {
    addTearDown(() => AuthService.setPassword(AuthService.defaultPassword));
    phoneSize(tester);
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Reset password'), findsOneWidget);

    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the code'), findsOneWidget);

    await tester.enterText(find.byType(TextField), AuthService.resetOtp);
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    expect(find.text('Save password'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'NewPass123');
    await tester.enterText(find.byType(TextField).at(1), 'NewPass123');
    await tester.tap(find.text('Save password'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
