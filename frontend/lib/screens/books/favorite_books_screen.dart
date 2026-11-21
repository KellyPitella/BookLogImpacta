import 'package:flutter/material.dart';

import '../../services/livro_service.dart';
import 'book_collection_screen.dart';

class FavoriteBooksScreen extends StatelessWidget {
  const FavoriteBooksScreen({super.key, this.livroService});

  final LivroService? livroService;

  @override
  Widget build(BuildContext context) => BookCollectionScreen(
    collection: BookCollection.favorites,
    livroService: livroService,
  );
}
