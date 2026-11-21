import 'package:flutter/material.dart';

import '../../services/livro_service.dart';
import 'book_collection_screen.dart';

class ReadBooksScreen extends StatelessWidget {
  const ReadBooksScreen({super.key, this.livroService});

  final LivroService? livroService;

  @override
  Widget build(BuildContext context) => BookCollectionScreen(
    collection: BookCollection.read,
    livroService: livroService,
  );
}
