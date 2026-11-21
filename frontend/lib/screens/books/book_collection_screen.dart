import 'package:flutter/material.dart';

import '../../core/widgets/book_card.dart';
import '../../models/book_model.dart';
import '../../services/livro_service.dart';
import 'add_book_screen.dart';
import 'book_details_screen.dart';

enum BookCollection { read, wantToRead, favorites }

class BookCollectionScreen extends StatefulWidget {
  const BookCollectionScreen({
    super.key,
    required this.collection,
    this.livroService,
  });

  final BookCollection collection;
  final LivroService? livroService;

  @override
  State<BookCollectionScreen> createState() => _BookCollectionScreenState();
}

class _BookCollectionScreenState extends State<BookCollectionScreen> {
  late final LivroService _livroService;
  List<BookModel> _books = [];
  bool _loading = true;
  String? _error;
  int? _busyId;
  final Set<int> _savingFavorites = {};

  @override
  void initState() {
    super.initState();
    _livroService = widget.livroService ?? LivroService();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await _livroService.listarLivros();
      if (!mounted) return;
      setState(() {
        _books = books.map(BookModel.fromJson).toList();
        _loading = false;
      });
    } catch (error, stack) {
      debugPrint('Erro ao carregar livros: $error\n$stack');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is LivroException
            ? error.message
            : 'Não foi possível carregar os livros. Tente novamente.';
      });
    }
  }

  Future<void> _open(BookModel book) async {
    await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailsScreen(
          book: book,
          livroService: _livroService,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _edit(BookModel book) async {
    final updated = await Navigator.push<BookModel>(
      context,
      MaterialPageRoute(builder: (_) => AddBookScreen(book: book)),
    );
    if (!mounted || updated == null) return;
    setState(() {
      final index = _books.indexWhere((item) => item.id == updated.id);
      if (index >= 0) _books[index] = updated;
    });
  }

  Future<void> _delete(BookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir livro?'),
        content: Text(
          'Deseja excluir "${book.titulo}"? O histórico de leitura também será removido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busyId = book.id);
    try {
      await _livroService.deletarLivro(book.id);
      if (!mounted) return;
      setState(() => _books.removeWhere((item) => item.id == book.id));
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
          title: const Text('Livro excluído com sucesso'),
          content: Text('"${book.titulo}" foi removido da sua estante.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error, stack) {
      debugPrint('Erro ao excluir livro: $error\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is LivroException
                ? error.message
                : 'Não foi possível excluir o livro.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _toggleFavorite(BookModel book) async {
    if (_savingFavorites.contains(book.id)) return;
    setState(() => _savingFavorites.add(book.id));
    try {
      final favorite = await _livroService.toggleFavorito(book.id);
      if (!mounted) return;
      setState(() {
        final index = _books.indexWhere((item) => item.id == book.id);
        if (index >= 0) _books[index] = _books[index].copyWith(favorito: favorite);
      });
    } catch (error, stack) {
      debugPrint('Erro ao atualizar favoritos: $error\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error is LivroException
              ? error.message
              : 'Não foi possível atualizar favoritos.')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingFavorites.remove(book.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = switch (widget.collection) {
      BookCollection.read => 'Lidos',
      BookCollection.wantToRead => 'Quero Ler',
      BookCollection.favorites => 'Favoritos',
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: _load, child: const Text('Tentar novamente')),
                ],
              ),
            )
          : Builder(
              builder: (context) {
                final books = _books.where((book) {
                  return switch (widget.collection) {
                    BookCollection.read => book.status == 'Lido',
                    BookCollection.wantToRead => book.status == 'QueroLer',
                    BookCollection.favorites => book.favorito,
                  };
                }).toList();
                final description = switch (widget.collection) {
                  BookCollection.read =>
                    '${books.length} ${books.length == 1 ? 'livro lido' : 'livros lidos'}',
                  BookCollection.wantToRead =>
                    '${books.length} ${books.length == 1 ? 'livro na fila de leitura' : 'livros na fila de leitura'}',
                  BookCollection.favorites =>
                    '${books.length} ${books.length == 1 ? 'livro favorito' : 'livros favoritos'}',
                };
                final emptyMessage = switch (widget.collection) {
                  BookCollection.read => 'Você ainda não concluiu nenhum livro',
                  BookCollection.wantToRead => 'Nenhum livro na lista de desejos',
                  BookCollection.favorites => 'Você ainda não favoritou nenhum livro',
                };
                final icon = switch (widget.collection) {
                  BookCollection.read => Icons.check_circle_outline,
                  BookCollection.wantToRead => Icons.bookmark_border,
                  BookCollection.favorites => Icons.favorite_border,
                };
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.collection == BookCollection.read
                            ? 'Cada livro concluído é uma nova conquista. Continue lendo!'
                            : widget.collection == BookCollection.wantToRead
                            ? 'Suas próximas jornadas começam aqui.'
                            : 'Os livros que conquistaram um lugar especial.',
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
                      ),
                      const SizedBox(height: 24),
                      if (books.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 56),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: colors.primaryContainer,
                                  child: Icon(icon, size: 36, color: colors.onPrimaryContainer),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  emptyMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sua próxima história está esperando por você.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.58,
                          ),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            return BookCard(
                              book: book,
                              onOpen: () => _open(book),
                              onEdit: () => _edit(book),
                              onDelete: () => _delete(book),
                              isFavorite: book.favorito,
                              onToggleFavorite: () => _toggleFavorite(book),
                              busy: _busyId == book.id || _savingFavorites.contains(book.id),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
