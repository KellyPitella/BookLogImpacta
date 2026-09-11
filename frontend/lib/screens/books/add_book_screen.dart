import 'package:flutter/material.dart';

import '../../services/livro_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _livroService = LivroService();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _generoController = TextEditingController();
  final _paginasController = TextEditingController();
  final _paginasLidasController = TextEditingController(text: '0');

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _generoController.dispose();
    _paginasController.dispose();
    _paginasLidasController.dispose();
    super.dispose();
  }

  Future<void> _salvarLivro() async {
    final titulo = _tituloController.text.trim();
    final autor = _autorController.text.trim();
    final genero = _generoController.text.trim();
    final totalPaginas = int.tryParse(_paginasController.text) ?? 0;

    if (titulo.isEmpty || autor.isEmpty || totalPaginas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os campos obrigatórios corretamente.'),
        ),
      );
      return;
    }

    try {
      await _livroService.criarLivro(
        titulo: titulo,
        autor: autor,
        genero: genero,
        totalPaginas: totalPaginas,
      );

      if (mounted) Navigator.pop(context, true);
    } on LivroException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final onPrimaryColor = colorScheme.onPrimary;
    final onPrimaryContainer = colorScheme.onPrimaryContainer;
    final onSurfaceColor = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final outlineColor = colorScheme.outline;
    final outlineVariant = colorScheme.outlineVariant;

    final cancelForeground = isDarkMode
        ? colorScheme.onSurface
        : colorScheme.primary;
    final cancelBorder = isDarkMode
        ? colorScheme.outlineVariant
        : colorScheme.primary.withValues(alpha: 0.5);
    final saveBackground = isDarkMode
        ? colorScheme.primaryContainer
        : colorScheme.primary;
    final saveForeground = isDarkMode ? onPrimaryContainer : onPrimaryColor;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: onSurfaceColor,
        title: Text(
          'Adicionar Livro',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: onSurfaceColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Preencha os detalhes da sua nova leitura.',
                  style: TextStyle(fontSize: 14, color: onSurfaceVariant),
                ),
                const SizedBox(height: 24),

                _buildLabel('TÍTULO DO LIVRO'),
                const SizedBox(height: 6),
                _buildUnderlineInput(
                  controller: _tituloController,
                  hintText: 'Ex: O Senhor dos Anéis',
                ),
                const SizedBox(height: 20),

                _buildLabel('AUTOR'),
                const SizedBox(height: 6),
                _buildUnderlineInput(
                  controller: _autorController,
                  hintText: 'Ex: J.R.R. Tolkien',
                ),
                const SizedBox(height: 20),

                _buildLabel('GÊNERO'),
                const SizedBox(height: 6),
                _buildUnderlineInput(
                  controller: _generoController,
                  hintText: 'Ex: Ficção, Romance, Fantasia',
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('TOTAL DE PÁGINAS'),
                          const SizedBox(height: 6),
                          _buildUnderlineInput(
                            controller: _paginasController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('PÁGINAS LIDAS'),
                          const SizedBox(height: 6),
                          _buildUnderlineInput(
                            controller: _paginasLidasController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                _buildLabel('CAPA (OPCIONAL)'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: outlineVariant,
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file_outlined,
                          size: 32,
                          color: outlineColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Arraste uma imagem ou clique para selecionar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cancelForeground,
                        side: BorderSide(color: cancelBorder),
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _salvarLivro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: saveBackground,
                        foregroundColor: saveForeground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                      child: const Text(
                        'Salvar Livro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Builder(
      builder: (context) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildUnderlineInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: colorScheme.outlineVariant,
              fontSize: 15,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        );
      },
    );
  }
}
