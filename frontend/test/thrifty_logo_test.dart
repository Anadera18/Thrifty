import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thrifty/features/auth/presentation/widgets/thrifty_logo.dart';

void main() {
  testWidgets('ThriftyLogo renders Image widget properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ThriftyLogo(size: 48),
        ),
      ),
    );

    expect(find.byType(ThriftyLogo), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
