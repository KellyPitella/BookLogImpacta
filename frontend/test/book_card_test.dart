import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/book_card.dart';
import 'package:frontend/models/book_model.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'compact card actions work in ${dark ? "dark" : "light"} theme',
      (tester) async {
        var favorite = false;
        var edits = 0;
        var deletes = 0;
        var opened = 0;
        final book = BookModel(
          id: 1,
          titulo: 'Livro',
          totalPaginas: 100,
          paginasLidas: 20,
          concluido: false,
          dataCadastro: DateTime(2026),
          percentual: 20,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 160,
                  height: 276,
                  child: StatefulBuilder(
                    builder: (context, setState) => BookCard(
                      book: book,
                      isFavorite: favorite,
                      onToggleFavorite: () =>
                          setState(() => favorite = !favorite),
                      onOpen: () => opened++,
                      onEdit: () => edits++,
                      onDelete: () => deletes++,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final card = tester.getRect(find.byType(BookCard));
        final heart = tester.getRect(find.byType(IconButton).first);
        final menu = tester.getRect(find.byType(PopupMenuButton<String>));
        final heartBackground = find.ancestor(
          of: find.byTooltip('Favoritar'),
          matching: find.byWidgetPredicate(
            (widget) => widget is Material && widget.shape is CircleBorder,
          ),
        );
        final menuBackground = find.ancestor(
          of: find.byType(PopupMenuButton<String>),
          matching: find.byWidgetPredicate(
            (widget) => widget is Material && widget.shape is CircleBorder,
          ),
        );
        expect(heartBackground, findsOneWidget);
        expect(menuBackground, findsOneWidget);
        expect(tester.getRect(heartBackground).size, const Size(30, 30));
        expect(tester.getRect(menuBackground).size, const Size(30, 30));
        expect(heart.size, const Size(30, 30));
        expect(menu.size, const Size(30, 30));
        expect(heart.topLeft - card.topLeft, const Offset(8, 8));
        expect(card.topRight.dx - menu.topRight.dx, 8);
        expect(menu.top - card.top, 8);
        expect(
          tester.widget<Icon>(find.byIcon(Icons.favorite_border)).size,
          18,
        );
        expect(tester.widget<Icon>(find.byIcon(Icons.more_vert)).size, 18);
        expect(tester.widget<Icon>(find.byIcon(Icons.auto_stories)).size, 32);

        await tester.tap(find.byTooltip('Favoritar'));
        await tester.pump();
        expect(find.byTooltip('Desfavoritar'), findsOneWidget);
        expect(tester.widget<Icon>(find.byIcon(Icons.favorite)).size, 18);
        expect(opened, 0);

        await tester.tap(find.byTooltip('Opções do livro'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();
        expect(edits, 1);
        expect(opened, 0);

        await tester.tap(find.byTooltip('Opções do livro'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();
        expect(deletes, 1);
        expect(opened, 0);

        await tester.tap(find.text('Livro'));
        expect(opened, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
