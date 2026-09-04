import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('BookLog app renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BookLogApp());

    expect(find.text('BookLog'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });
}
