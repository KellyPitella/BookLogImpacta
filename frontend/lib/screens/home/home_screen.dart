import 'package:flutter/material.dart';

import '../../core/widgets/app_settings_sheet.dart';
import '../books/add_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _logoAssetPath = 'assets/images/BookLog_Logo.png';

  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;

  final List<String> _categories = [
    'Lendo (3)',
    'Lidos (12)',
    'Quero Ler (8)',
    'Favoritos',
  ];

  final List<Map<String, dynamic>> _books = [
    {
      'title': 'O Vento Frio da Montanha',
      'author': 'Elena Rostova',
      'progress': 0.64,
      'percentage': 64,
      'coverColor': Color(0xFF5D8068),
    },
    {
      'title': 'Silêncio Botânico',
      'author': 'Arthur P. Mendes',
      'progress': 0.21,
      'percentage': 21,
      'coverColor': Color(0xFF204430),
    },
    {
      'title': 'A Arquitetura do Vazio',
      'author': 'L. S. Vygotsky',
      'progress': 0.89,
      'percentage': 89,
      'coverColor': Color(0xFF45634F),
    },
  ];

  // Cores de marca (fixas nos dois temas)
  static const Color primaryColor = Color(0xFF16332D); // Verde Floresta
  static const Color secondaryContainer = Color(0xFFC9E8CB);
  static const Color tertiaryFixedDim = Color(
    0xFFF5BB88,
  ); // Terracota / Pêssego

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final brandColor = isDarkMode ? colorScheme.primary : primaryColor;
    final chipSelectedColor = isDarkMode ? colorScheme.primary : primaryColor;
    final chipTextColor = isDarkMode ? colorScheme.onPrimary : Colors.white;
    final onSurfaceColor = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final outlineVariant = colorScheme.outlineVariant;
    final surfaceContainer = colorScheme.surfaceContainer;
    final surfaceContainerHigh = colorScheme.surfaceContainerHigh;

    return Scaffold(
      // --- TopAppBar ---
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surfaceContainerHigh,
                border: Border.all(
                  color: outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  _logoAssetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person_outline,
                      size: 20,
                      color: onSurfaceVariant,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'BookLog',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: brandColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (appBarContext) => IconButton(
              onPressed: () => showAppSettingsMenu(appBarContext),
              icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      // --- Body ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            Text(
              'Sua Estante',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: onSurfaceColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Continue de onde parou e descubra novas jornadas.',
              style: TextStyle(fontSize: 15, color: onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Chips de Categoria (Rolagem Horizontal)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? chipSelectedColor : surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? chipTextColor : onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Grid de Livros (2 colunas)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              itemCount: _books.length + 1, // +1 para o card "Novo Livro"
              itemBuilder: (context, index) {
                if (index < _books.length) {
                  final book = _books[index];
                  return _buildBookCard(
                    title: book['title'] as String,
                    author: book['author'] as String,
                    progress: book['progress'] as double,
                    percentage: book['percentage'] as int,
                    coverColor: book['coverColor'] as Color,
                  );
                } else {
                  return _buildAddNewBookCard();
                }
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // --- Botão Flutuante (FAB) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-book');
        },
        backgroundColor: isDarkMode ? colorScheme.primary : primaryColor,
        foregroundColor: isDarkMode ? colorScheme.onPrimary : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: outlineVariant.withValues(alpha: 0.3)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, label: 'Início', index: 0),
            _buildNavItem(
              icon: Icons.add_circle_outline,
              label: 'Adicionar',
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.leaderboard_outlined,
              label: 'Estatísticas',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  // Card do Livro
  Widget _buildBookCard({
    required String title,
    required String author,
    required double progress,
    required int percentage,
    required Color coverColor,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/book-details');
          },
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
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
                // Capa do Livro (Mockup elegante)
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    color: coverColor,
                    child: const Center(
                      child: Icon(
                        Icons.auto_stories,
                        size: 36,
                        color: Color(0xFFC9E8CB),
                      ),
                    ),
                  ),
                ),
                // Informações e Progresso
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progresso',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 5,
                                backgroundColor: colorScheme.surfaceContainer,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  tertiaryFixedDim,
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
        );
      },
    );
  }

  // Card Tracejado: Adicionar Novo Livro
  Widget _buildAddNewBookCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDarkMode = theme.brightness == Brightness.dark;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBookScreen()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        colorScheme.surfaceContainerLow,
                      ]
                    : [
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                        colorScheme.surfaceContainerLow,
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? colorScheme.primary.withValues(alpha: 0.42)
                    : primaryColor.withValues(alpha: 0.18),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: isDarkMode
                      ? colorScheme.primary.withValues(alpha: 0.16)
                      : secondaryContainer,
                  child: Icon(
                    Icons.add,
                    color: isDarkMode ? colorScheme.primary : primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Novo Livro',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Buscar ou escanear',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Item da Bottom Bar
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentNavIndex == index;

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;

        if (isSelected) {
          final selectedFill = isDarkMode
              ? theme.colorScheme.primary
              : secondaryContainer;
          final selectedText = isDarkMode
              ? theme.colorScheme.onPrimary
              : primaryColor;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: selectedFill,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: selectedText),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selectedText,
                  ),
                ),
              ],
            ),
          );
        }

        return InkWell(
          onTap: () {
            setState(() {
              _currentNavIndex = index;
            });
            if (index == 1) {
              Navigator.pushNamed(context, '/add-book');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/summary');
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
