import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../../services/livro_service.dart';

class BookCoverImage extends StatefulWidget {
  final BookModel book;
  final Widget fallback;

  const BookCoverImage({
    super.key,
    required this.book,
    required this.fallback,
  });

  @override
  State<BookCoverImage> createState() => _BookCoverImageState();
}

class _BookCoverImageState extends State<BookCoverImage> {
  static final Map<int, Uint8List> _cache = {};
  static final LivroService _bookService = LivroService();

  Uint8List? _bytes;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCapa();
  }

  @override
  void didUpdateWidget(BookCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book.id != widget.book.id ||
        oldWidget.book.capaArquivo != widget.book.capaArquivo) {
      _bytes = null;
      _carregando = true;
      _carregarCapa();
    }
  }

  Future<void> _carregarCapa() async {
    final book = widget.book;

    if (book.capaArquivo == null || book.capaArquivo!.isEmpty) {
      if (mounted) setState(() => _carregando = false);
      return;
    }

    final emCache = _cache[book.id];
    if (emCache != null) {
      if (mounted) {
        setState(() {
          _bytes = emCache;
          _carregando = false;
        });
      }
      return;
    }

    try {
      final bytes = await _bookService.downloadCapa(book.id);
      if (!mounted) return;
      if (bytes != null) _cache[book.id] = bytes;
      setState(() {
        _bytes = bytes;
        _carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;

    if (_carregando || bytes == null) {
      return widget.fallback;
    }

    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, _, _) => widget.fallback,
    );
  }
}
