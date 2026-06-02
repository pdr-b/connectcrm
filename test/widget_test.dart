import 'package:connectcrm/shared/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GradientButton renders its label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientButton(label: 'Entrar', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);
  });
}
