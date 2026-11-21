import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../theme/app_colors.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.busy = false,
  });

  final BookModel book;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onOpen,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      color: AppColors.primary,
                      child: const Center(
                        child: Icon(
                          Icons.auto_stories,
                          size: 32,
                          color: AppColors.secondaryContainer,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    book.titulo,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Flexible(
                                  child: Text(
                                    book.autor ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Progresso',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${book.percentualInt}%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: book.progressFactor,
                                  minHeight: 5,
                                  backgroundColor: colors.surfaceContainer,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.tertiaryFixedDim,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Material(
            color: Colors.black.withValues(alpha: 0.3),
            shape: const CircleBorder(),
            child: SizedBox(
              width: 30,
              height: 30,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                tooltip: isFavorite ? 'Desfavoritar' : 'Favoritar',
                onPressed: busy ? null : onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isFavorite ? AppColors.tertiaryFixedDim : Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black.withValues(alpha: 0.3),
            shape: const CircleBorder(),
            child: SizedBox(
              width: 30,
              height: 30,
              child: PopupMenuButton<String>(
                tooltip: 'Opções do livro',
                enabled: !busy,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(15),
                onSelected: (option) {
                  if (option == 'edit') {
                    onEdit();
                  } else if (option == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 12),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: colors.error),
                        const SizedBox(width: 12),
                        Text('Excluir', style: TextStyle(color: colors.error)),
                      ],
                    ),
                  ),
                ],
                child: const Center(
                  child: Icon(Icons.more_vert, size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
