import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/screens/books/book_details_screen.dart';
import 'package:frontend/screens/books/favorite_books_screen.dart';
import 'package:frontend/screens/books/read_books_screen.dart';
import 'package:frontend/screens/books/want_to_read_screen.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/services/livro_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> book(int id, String title, int pages, bool done) => {
  'id': id,
  'titulo': title,
  'autor': 'Autor',
  'genero': 'Ficção',
  'totalPaginas': 100,
  'paginasLidas': pages,
  'concluido': done,
  'status': done ? 'Lido' : pages > 0 ? 'Lendo' : 'QueroLer',
  'favorito': id == 3,
  'dataCadastro': '2026-01-01T00:00:00.000Z',
  'percentual': pages,
};

class FakeLivroService extends LivroService {
  FakeLivroService(this.books);

  final List<Map<String, dynamic>> books;
  bool fail = false;
  bool failToggle = false;
  Completer<void>? toggleGate;
  int toggleCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> listarLivros({String? status, bool? favoritos}) async {
    if (fail) throw LivroException('Erro ao carregar estante');
    return books.where((book) =>
        (status == null || book['status'] == status) &&
        (favoritos != true || book['favorito'] == true))
        .map((book) => Map<String, dynamic>.of(book)).toList();
  }

  @override
  Future<bool> toggleFavorito(int livroId) async {
    toggleCalls++;
    if (toggleGate != null) await toggleGate!.future;
    if (failToggle) throw LivroException('Falha ao salvar favorito');
    final item = books.firstWhere((book) => book['id'] == livroId);
    final value = !(item['favorito'] as bool);
    item['favorito'] = value;
    return value;
  }

  @override
  Future<void> deletarLivro(int livroId) async {
    books.removeWhere((book) => book['id'] == livroId);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_user': jsonEncode({
        'id': 1,
        'nome': 'Leitor',
        'email': 'reader@example.com',
      }),
      'favorite_book_ids_1': ['3'],
    });
  });

  for (final dark in [false, true]) {
    testWidgets(
      'filters collections and displays counts in ${dark ? "dark" : "light"} theme',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final service = FakeLivroService([
          book(1, 'Livro lido', 100, true),
          book(2, 'Livro na fila', 0, false),
          book(3, 'Livro favorito', 20, false),
          book(4, 'Concluído sem páginas', 0, true),
        ]);
        Future<void> show(Widget screen) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: screen,
            ),
          );
          await tester.pumpAndSettle();
        }

        await show(
          ReadBooksScreen(livroService: service),
        );
        expect(find.text('2 livros lidos'), findsOneWidget);
        expect(find.text('Livro lido'), findsOneWidget);
        expect(find.text('Concluído sem páginas'), findsOneWidget);
        expect(find.text('Livro na fila'), findsNothing);

        await show(
          WantToReadScreen(livroService: service),
        );
        expect(find.text('1 livro na fila de leitura'), findsOneWidget);
        expect(find.text('Livro na fila'), findsOneWidget);
        expect(find.text('Concluído sem páginas'), findsNothing);

        await show(
          FavoriteBooksScreen(
            livroService: service,
          ),
        );
        expect(find.text('1 livro favorito'), findsOneWidget);
        expect(find.text('Livro favorito'), findsOneWidget);
        expect(find.text('Livro lido'), findsNothing);
        await tester.tap(find.byTooltip('Desfavoritar'));
        await tester.pumpAndSettle();
        expect(
          find.text('Você ainda não favoritou nenhum livro'),
          findsOneWidget,
        );
        expect(service.books[2]['favorito'], isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('empty collections show their respective messages', (
    tester,
  ) async {
    final service = FakeLivroService([]);
    for (final entry in <(Widget, String)>[
      (
        ReadBooksScreen(livroService: service),
        'Você ainda não concluiu nenhum livro',
      ),
      (
        WantToReadScreen(livroService: service),
        'Nenhum livro na lista de desejos',
      ),
      (
        FavoriteBooksScreen(livroService: service),
        'Você ainda não favoritou nenhum livro',
      ),
    ]) {
      await tester.pumpWidget(MaterialApp(home: entry.$1));
      await tester.pumpAndSettle();
      expect(find.text(entry.$2), findsOneWidget);
    }
  });

  testWidgets('deletion asks for confirmation and updates the list', (
    tester,
  ) async {
    final service = FakeLivroService([book(1, 'Livro lido', 100, true)]);
    await tester.pumpWidget(
      MaterialApp(home: ReadBooksScreen(livroService: service)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Opções do livro'));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsOneWidget);
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    expect(find.text('Excluir livro?'), findsOneWidget);
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    expect(find.text('Livro excluído com sucesso'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Você ainda não concluiu nenhum livro'), findsOneWidget);
    expect(service.books, isEmpty);
  });

  testWidgets('opens details and refreshes the collection on return', (
    tester,
  ) async {
    final service = FakeLivroService([book(1, 'Livro lido', 100, true)]);
    await tester.pumpWidget(
      MaterialApp(home: ReadBooksScreen(livroService: service)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Livro lido'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Livro lido'));
    await tester.pumpAndSettle();
    expect(find.byType(BookDetailsScreen), findsOneWidget);
    service.books[0] = book(1, 'Livro atualizado', 100, true);
    await tester.tap(find.text('Voltar para Biblioteca'));
    await tester.pumpAndSettle();
    expect(find.text('Livro atualizado'), findsOneWidget);
  });

  testWidgets('edit action opens the existing editor', (tester) async {
    final service = FakeLivroService([book(1, 'Livro lido', 100, true)]);
    await tester.pumpWidget(
      MaterialApp(home: ReadBooksScreen(livroService: service)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Opções do livro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(find.text('Editar Livro'), findsOneWidget);
  });

  testWidgets('load errors are visible and can be retried', (tester) async {
    final service = FakeLivroService([book(1, 'Livro lido', 100, true)])
      ..fail = true;
    await tester.pumpWidget(
      MaterialApp(home: ReadBooksScreen(livroService: service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Erro ao carregar estante'), findsOneWidget);
    service.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Livro lido'), findsOneWidget);
  });

  testWidgets('home opens collections and shares favorites', (tester) async {
    final service = FakeLivroService([
      book(1, 'Livro lido', 100, true),
      book(2, 'Livro na fila', 0, false),
      book(4, 'Livro em andamento', 20, false),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(livroService: service),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lendo (1)'), findsOneWidget);
    expect(find.text('Lidos (1)'), findsOneWidget);
    expect(find.text('Quero Ler (1)'), findsOneWidget);
    await tester.ensureVisible(find.text('Favoritos (0)'));
    expect(find.text('Favoritos (0)'), findsOneWidget);
    await tester.tap(find.byTooltip('Favoritar').first);
    await tester.pumpAndSettle();
    expect(find.text('Favoritos (1)'), findsOneWidget);
    await tester.tap(find.text('Lidos (1)'));
    await tester.pumpAndSettle();
    expect(find.text('1 livro lido'), findsOneWidget);
    expect(find.byTooltip('Desfavoritar'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero Ler (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Livro na fila'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Favoritos (1)'));
    await tester.tap(find.text('Favoritos (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Livro lido'), findsOneWidget);
    await tester.tap(find.byTooltip('Desfavoritar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Desfavoritar'), findsNothing);
    expect(find.text('Favoritos (0)'), findsOneWidget);
  });

  testWidgets('details favorites update the home count and card immediately', (
    tester,
  ) async {
    final service = FakeLivroService([book(1, 'Livro lido', 100, true)]);
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(livroService: service),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Livro lido'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Livro lido'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Favoritar'), findsOneWidget);
    await tester.tap(find.byTooltip('Favoritar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Desfavoritar'), findsOneWidget);
    service.books[0] = book(1, 'Livro lido', 20, false)..['favorito'] = true;
    await tester.tap(find.text('Voltar para Biblioteca'));
    await tester.pumpAndSettle();
    expect(find.text('Lendo (1)'), findsOneWidget);
    expect(find.text('Lidos (0)'), findsOneWidget);
    await tester.ensureVisible(find.text('Favoritos (1)'));
    expect(find.text('Favoritos (1)'), findsOneWidget);
    expect(find.byTooltip('Desfavoritar'), findsOneWidget);
    expect(service.books[0]['favorito'], isTrue);
  });

  testWidgets('unfavoriting in details removes a book from favorites', (
    tester,
  ) async {
    final service = FakeLivroService([book(3, 'Livro favorito', 20, false)]);
    await tester.pumpWidget(
      MaterialApp(home: FavoriteBooksScreen(livroService: service)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Livro favorito'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Desfavoritar'), findsOneWidget);
    await tester.tap(find.byTooltip('Desfavoritar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar para Biblioteca'));
    await tester.pumpAndSettle();
    expect(find.text('Você ainda não favoritou nenhum livro'), findsOneWidget);
  });

  testWidgets('failed favorite update leaves the heart unchanged', (tester) async {
    final service = FakeLivroService([book(1, 'Livro lido', 100, true)])..failToggle = true;
    await tester.pumpWidget(MaterialApp(home: ReadBooksScreen(livroService: service)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favoritar'));
    await tester.pumpAndSettle();
    expect(find.text('Falha ao salvar favorito'), findsOneWidget);
    expect(find.byTooltip('Favoritar'), findsOneWidget);
    expect(service.books[0]['favorito'], isFalse);
  });

  testWidgets('a pending favorite update prevents duplicate requests', (
    tester,
  ) async {
    final service = FakeLivroService([book(1, 'Livro lido', 100, true)])
      ..toggleGate = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(home: ReadBooksScreen(livroService: service)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favoritar'));
    await tester.pump();
    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.favorite_border),
    );
    expect(button.onPressed, isNull);
    expect(service.toggleCalls, 1);
    service.toggleGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Desfavoritar'), findsOneWidget);
  });

  testWidgets('status takes precedence over pages and completion in collections', (tester) async {
    final service = FakeLivroService([
      book(1, 'Fila mesmo com páginas', 100, false)..['status'] = 'QueroLer',
      book(2, 'Lido mesmo incompleto', 0, false)..['status'] = 'Lido',
    ]);
    await tester.pumpWidget(MaterialApp(home: ReadBooksScreen(livroService: service)));
    await tester.pumpAndSettle();
    expect(find.text('Lido mesmo incompleto'), findsOneWidget);
    expect(find.text('Fila mesmo com páginas'), findsNothing);
    await tester.pumpWidget(MaterialApp(home: WantToReadScreen(livroService: service)));
    await tester.pumpAndSettle();
    expect(find.text('Fila mesmo com páginas'), findsOneWidget);
    expect(find.text('Lido mesmo incompleto'), findsNothing);
  });
}
