import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/screens/books/favorite_books_screen.dart';
import 'package:frontend/screens/books/read_books_screen.dart';
import 'package:frontend/screens/books/want_to_read_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('BookLog app renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BookLogApp());

    expect(find.text('BookLog'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });

  testWidgets('BookLog registers collection routes', (tester) async {
    await tester.pumpWidget(const BookLogApp());
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final context = tester.element(find.byType(MaterialApp));
    final routes = app.routes!;
    expect(routes['/lidos']!(context), isA<ReadBooksScreen>());
    expect(routes['/quero-ler']!(context), isA<WantToReadScreen>());
    expect(routes['/favoritos']!(context), isA<FavoriteBooksScreen>());
  });
}
