import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/screens/home/statistics_screen.dart';
import 'package:frontend/services/progress_service.dart';

class _FakeProgressService extends ProgressService {
  int requests = 0;

  @override
  Future<ReadingStatistics> getEstatisticas(int ano) async {
    requests++;
    final today = DateTime.now();
    return ReadingStatistics(
      ano: ano,
      livrosConcluidos: 3,
      paginasLidas: 120,
      mediaDiaria: 20,
      mediaPorLivro: 40,
      diasDeLeitura: 6,
      maiorSequencia: 4,
      livrosConcluidosSemData: 0,
      anosDisponiveis: [ano],
      meses: List.generate(
        12,
        (index) => MonthlyReadingStatistics(
          mes: index + 1,
          livrosConcluidos: 0,
          paginasLidas: 0,
        ),
      ),
      atividade: [
        ReadingActivityDay(
          data: DateTime(today.year, today.month, today.day),
          paginasLidas: 25,
        ),
      ],
    );
  }
}

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'statistics shows real data in ${dark ? "dark" : "light"} theme',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: StatisticsScreen(progressService: _FakeProgressService()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Estatísticas de Leitura'), findsOneWidget);
        expect(find.text('PÁGINAS LIDAS'), findsOneWidget);
        expect(find.text('120'), findsOneWidget);
        expect(find.text('RITMO DIÁRIO'), findsOneWidget);
        expect(find.text('20,0 páginas'), findsOneWidget);
        expect(find.text('Estatísticas'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.text('Ritmo semanal'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Ritmo semanal'), findsOneWidget);
        expect(
          find.byTooltip(
            '${DateTime.now().day}/${DateTime.now().month}: 25 páginas',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('bottom navigation opens add book and returns home', (
    tester,
  ) async {
    final service = _FakeProgressService();
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/add-book': (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar do cadastro'),
            ),
          ),
        },
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => StatisticsScreen(progressService: service),
                ),
              ),
              child: const Text('Abrir estatísticas'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir estatísticas'));
    await tester.pumpAndSettle();
    expect(service.requests, 1);
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    expect(find.text('Voltar do cadastro'), findsOneWidget);
    await tester.tap(find.text('Voltar do cadastro'));
    await tester.pumpAndSettle();
    expect(service.requests, 2);
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir estatísticas'), findsOneWidget);
  });
}
