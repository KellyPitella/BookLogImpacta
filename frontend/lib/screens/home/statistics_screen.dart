import 'package:flutter/material.dart';

import '../../core/widgets/app_settings_sheet.dart';
import '../../services/progress_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, this.progressService});

  final ProgressService? progressService;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _brandDark = Color(0xFF16332D);
  static const _brandContainer = Color(0xFF2D4A43);
  static const _brandLight = Color(0xFFCBE3DB);
  static const _surfaceBackground = Color(0xFFF9F9F8);
  static const _surfaceCard = Colors.white;
  static const _borderLight = Color(0xFFE5E7EB);
  static const _textMuted = Color(0xFF78716C);

  static const _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const _shortMonths = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  late final ProgressService _progressService;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  ReadingStatistics? _statistics;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _progressService = widget.progressService ?? ProgressService();
    _loadStatistics();
  }

  Future<void> _loadStatistics({int? year}) async {
    if (year != null) _selectedYear = year;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final statistics = await _progressService.getEstatisticas(_selectedYear);
      if (!mounted) return;
      setState(() {
        _statistics = statistics;
        _loading = false;
      });
    } on ProgressException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _loading = false;
      });
    }
  }

  String _formatCount(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
  }

  String _formatAverage(double value) =>
      value.toStringAsFixed(1).replaceFirst('.', ',');

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final statistics = _statistics;
    final years = [...?statistics?.anosDisponiveis];
    if (years.isEmpty) years.add(_selectedYear);
    if (!years.contains(_selectedYear)) years.add(_selectedYear);

    return Scaffold(
      backgroundColor: isDarkMode ? colorScheme.surface : _surfaceBackground,
      appBar: AppBar(
        backgroundColor: isDarkMode ? colorScheme.surface : _surfaceBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/BookLog_Logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'BookLog',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? colorScheme.primary : _brandDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (appBarContext) => IconButton(
              onPressed: () => showAppSettingsMenu(appBarContext),
              icon: Icon(Icons.settings_outlined, color: colorScheme.primary),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: _loading && statistics == null
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && statistics == null
            ? _buildError(colorScheme)
            : statistics == null
            ? const SizedBox.shrink()
            : _buildContent(statistics, years, colorScheme, isDarkMode),
      ),
      bottomNavigationBar: _buildBottomNavigation(colorScheme, isDarkMode),
    );
  }

  Widget _buildError(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Não foi possível carregar as estatísticas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadStatistics,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    ReadingStatistics statistics,
    List<int> years,
    ColorScheme colorScheme,
    bool isDarkMode,
  ) {
    final selectedMonth = statistics.meses.firstWhere(
      (month) => month.mes == _selectedMonth,
    );
    final hasActivity = statistics.diasDeLeitura > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estatísticas de Leitura',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? colorScheme.onSurface
                                : _brandDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Acompanhe seus hábitos e sua evolução.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? colorScheme.onSurfaceVariant
                                : _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _selectedYear,
                    borderRadius: BorderRadius.circular(12),
                    underline: const SizedBox.shrink(),
                    style: TextStyle(
                      color: isDarkMode
                          ? colorScheme.onSurface
                          : _brandContainer,
                      fontWeight: FontWeight.w700,
                    ),
                    items: years
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text('$year'),
                          ),
                        )
                        .toList(),
                    onChanged: _loading
                        ? null
                        : (year) {
                            if (year != null && year != _selectedYear) {
                              _loadStatistics(year: year);
                            }
                          },
                  ),
                ],
              ),
              if (_loading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildInlineError(colorScheme),
              ],
              const SizedBox(height: 20),
              _buildSummaryCards(statistics),
              const SizedBox(height: 12),
              _buildDailyPace(statistics),
              const SizedBox(height: 12),
              _buildReadingHabits(statistics, colorScheme),
              if (!hasActivity) ...[
                const SizedBox(height: 20),
                _buildInformationCard(
                  colorScheme,
                  icon: Icons.menu_book_outlined,
                  message:
                      'Nenhuma leitura registrada em $_selectedYear. Registre seu progresso para acompanhar suas estatísticas.',
                ),
              ],
              if (statistics.livrosConcluidosSemData > 0) ...[
                const SizedBox(height: 12),
                _buildInformationCard(
                  colorScheme,
                  icon: Icons.info_outline,
                  message:
                      '${statistics.livrosConcluidosSemData} livro(s) concluído(s) não têm histórico suficiente para identificar a data de conclusão e não foram atribuídos a um ano.',
                ),
              ],
              const SizedBox(height: 20),
              _buildWeeklyChart(statistics, colorScheme),
              const SizedBox(height: 20),
              _buildActivityCalendar(statistics, colorScheme),
              const SizedBox(height: 20),
              _buildMonthlyChart(statistics, selectedMonth, colorScheme),
              const SizedBox(height: 12),
              _buildSummaryCard(
                _SummaryCardData(
                  label: 'Média por livro',
                  value: _formatAverage(statistics.mediaPorLivro),
                  detail: 'páginas por livro concluído',
                  icon: Icons.analytics_outlined,
                ),
                colorScheme,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineError(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: _loadStatistics,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ReadingStatistics statistics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colorScheme = Theme.of(context).colorScheme;
        const columns = 2;
        const spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final cards = [
          _SummaryCardData(
            label: 'Páginas lidas',
            value: _formatCount(statistics.paginasLidas),
            detail: 'no ano',
            icon: Icons.auto_stories_outlined,
          ),
          _SummaryCardData(
            label: 'Livros concluídos',
            value: _formatCount(statistics.livrosConcluidos),
            detail: 'no ano',
            icon: Icons.menu_book_outlined,
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: _buildSummaryCard(card, colorScheme),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildSummaryCard(_SummaryCardData card, ColorScheme colorScheme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 132,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surfaceContainerLow : _surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? colorScheme.outlineVariant : _borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  card.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode
                        ? colorScheme.onSurfaceVariant
                        : _textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? colorScheme.surfaceContainerHighest
                      : const Color(0xFFF0F5F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  card.icon,
                  size: 16,
                  color: isDarkMode ? colorScheme.primary : _brandContainer,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            card.value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? colorScheme.onSurface : _brandDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            card.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPace(ReadingStatistics statistics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _brandContainer,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _brandContainer.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.schedule,
              size: 88,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: _brandLight),
                  SizedBox(width: 6),
                  Text(
                    'RITMO DIÁRIO',
                    style: TextStyle(
                      color: _brandLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${_formatAverage(statistics.mediaDiaria)} páginas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Em média por dia de leitura',
                style: TextStyle(color: _brandLight, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(
    ReadingStatistics statistics,
    ColorScheme colorScheme,
  ) {
    final today = DateTime.now();
    final end = _selectedYear == today.year
        ? DateTime(today.year, today.month, today.day)
        : DateTime(_selectedYear, 12, 31);
    final startOfYear = DateTime(_selectedYear, 1, 1);
    final activityByDate = {
      for (final day in statistics.atividade)
        _dateKey(day.data): day.paginasLidas,
    };
    final dates = List.generate(
      7,
      (index) => DateTime(end.year, end.month, end.day - (6 - index)),
    ).where((date) => !date.isBefore(startOfYear)).toList();
    final values = dates
        .map((date) => activityByDate[_dateKey(date)] ?? 0)
        .toList();
    final maximum = values.fold<int>(0, (a, b) => a > b ? a : b);
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return _sectionCard(
      colorScheme,
      title: 'Ritmo semanal',
      subtitle:
          'Páginas lidas de ${dates.first.day}/${dates.first.month} a ${end.day}/${end.month}',
      child: SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(dates.length, (index) {
            final count = values[index];
            final date = dates[index];
            return Expanded(
              child: Tooltip(
                message: '${date.day}/${date.month}: $count páginas',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatCount(count),
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: maximum == 0 ? 3 : 3 + 80 * count / maximum,
                      decoration: BoxDecoration(
                        color: count == 0
                            ? colorScheme.surfaceContainerHighest
                            : _brandContainer,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weekdays[date.weekday - 1],
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(ColorScheme colorScheme, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surface : _surfaceBackground,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? colorScheme.outlineVariant : _borderLight,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Início'),
                  ),
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/add-book');
                      if (mounted) await _loadStatistics();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Adicionar'),
                  ),
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? colorScheme.surfaceContainerHighest
                          : _brandLight,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.leaderboard,
                          size: 18,
                          color: isDarkMode
                              ? colorScheme.onSurface
                              : _brandDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Estatísticas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? colorScheme.onSurface
                                : _brandDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationCard(
    ColorScheme colorScheme, {
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(
    ReadingStatistics statistics,
    MonthlyReadingStatistics selectedMonth,
    ColorScheme colorScheme,
  ) {
    final maximumBooks = statistics.meses.fold<int>(
      0,
      (maximum, month) =>
          month.livrosConcluidos > maximum ? month.livrosConcluidos : maximum,
    );

    return _sectionCard(
      colorScheme,
      title: 'Evolução mensal',
      subtitle: 'Livros concluídos em cada mês de $_selectedYear',
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: statistics.meses.map((month) {
                final isSelected = month.mes == _selectedMonth;
                final count = month.livrosConcluidos;
                final barHeight = maximumBooks == 0
                    ? 3.0
                    : 8 + (count / maximumBooks * 82);
                final barColor = maximumBooks == 0
                    ? colorScheme.surfaceContainerHighest
                    : isSelected
                    ? colorScheme.primary
                    : colorScheme.secondaryContainer;

                return Expanded(
                  child: Tooltip(
                    message:
                        '${_months[month.mes - 1]}: $count livro(s) concluído(s)',
                    child: InkWell(
                      onTap: () => setState(() => _selectedMonth = month.mes),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 96,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 18,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _shortMonths[month.mes - 1],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8,
              children: [
                Text(
                  _months[_selectedMonth - 1],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${selectedMonth.livrosConcluidos} concluído(s)  ·  '
                  '${_formatCount(selectedMonth.paginasLidas)} páginas lidas',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingHabits(
    ReadingStatistics statistics,
    ColorScheme colorScheme,
  ) {
    return _sectionCard(
      colorScheme,
      title: 'Sequência de leitura',
      subtitle: 'Sua frequência de leitura em $_selectedYear',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 12.0;
          final cardWidth = (constraints.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              SizedBox(
                width: cardWidth,
                child: _buildHabitCard(
                  colorScheme,
                  icon: Icons.event_available_outlined,
                  title: 'Dias de leitura',
                  value: '${statistics.diasDeLeitura}',
                  detail: 'dias com registro',
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: _buildHabitCard(
                  colorScheme,
                  icon: Icons.local_fire_department_outlined,
                  title: 'Maior sequência',
                  value: '${statistics.maiorSequencia}',
                  detail: 'dias consecutivos',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHabitCard(
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String value,
    required String detail,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surfaceContainer : _surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? colorScheme.outlineVariant : _borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? colorScheme.surfaceContainerHighest
                  : const Color(0xFFF0F5F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? colorScheme.primary : _brandContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? colorScheme.onSurface : _brandDark,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCalendar(
    ReadingStatistics statistics,
    ColorScheme colorScheme,
  ) {
    final activityByDate = {
      for (final day in statistics.atividade)
        _dateKey(day.data): day.paginasLidas,
    };
    final firstDayOfYear = DateTime(_selectedYear, 1, 1);
    final firstCalendarDay = firstDayOfYear.subtract(
      Duration(days: firstDayOfYear.weekday - 1),
    );
    final nextYear = DateTime(_selectedYear + 1, 1, 1);
    final totalCalendarDays = nextYear.difference(firstCalendarDay).inDays;
    final weekCount = (totalCalendarDays + 6) ~/ 7;
    final calendarWidth = weekCount * 15.0 + 25;

    return _sectionCard(
      colorScheme,
      title: 'Frequência de leitura',
      subtitle: 'Cada quadrado representa um dia do ano',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: calendarWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: _shortMonths
                        .map(
                          (month) => Expanded(
                            child: Text(
                              month,
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        child: Column(
                          children: List.generate(7, (weekday) {
                            final label = switch (weekday) {
                              0 => 'S',
                              2 => 'Q',
                              4 => 'S',
                              6 => 'D',
                              _ => '',
                            };
                            return SizedBox(
                              height: 15,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ...List.generate(weekCount, (week) {
                        return SizedBox(
                          width: 15,
                          child: Column(
                            children: List.generate(7, (weekday) {
                              final date = firstCalendarDay.add(
                                Duration(days: week * 7 + weekday),
                              );
                              if (date.year != _selectedYear) {
                                return const SizedBox(width: 11, height: 15);
                              }

                              final pagesRead =
                                  activityByDate[_dateKey(date)] ?? 0;
                              return SizedBox(
                                height: 15,
                                child: Center(
                                  child: Tooltip(
                                    message: pagesRead == 0
                                        ? '${date.day}/${date.month}: sem leitura registrada'
                                        : '${date.day}/${date.month}: $pagesRead páginas lidas',
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: _activityColor(
                                          pagesRead,
                                          colorScheme,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Menos',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              for (final pages in [0, 1, 20, 50]) ...[
                Container(
                  width: 11,
                  height: 11,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: _activityColor(pages, colorScheme),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
              const SizedBox(width: 3),
              Text(
                'Mais',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _activityColor(int pagesRead, ColorScheme colorScheme) {
    if (pagesRead == 0) return colorScheme.surfaceContainerHighest;
    if (Theme.of(context).brightness == Brightness.dark) {
      if (pagesRead <= 10) return colorScheme.secondaryContainer;
      if (pagesRead <= 30) return colorScheme.primary.withValues(alpha: 0.65);
      return colorScheme.primary;
    }
    if (pagesRead <= 10) return _brandLight;
    if (pagesRead <= 30) return const Color(0xFF629084);
    return _brandContainer;
  }

  Widget _sectionCard(
    ColorScheme colorScheme, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surfaceContainerLow : _surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? colorScheme.outlineVariant : _borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? colorScheme.onSurface : _brandDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SummaryCardData {
  final String label;
  final String value;
  final String detail;
  final IconData icon;

  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });
}
