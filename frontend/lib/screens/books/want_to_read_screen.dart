import 'package:flutter/material.dart';

import '../../services/livro_service.dart';
import 'book_collection_screen.dart';

class WantToReadScreen extends StatelessWidget {
  const WantToReadScreen({super.key, this.livroService});

  final LivroService? livroService;

  @override
  Widget build(BuildContext context) => BookCollectionScreen(
    collection: BookCollection.wantToRead,
    livroService: livroService,
  );
}
