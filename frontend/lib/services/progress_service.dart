import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class ProgressItem {
  final int id;
  final DateTime data;
  final int paginasLidas;
  final String? nota;
  final int livroId;
  final String? livroTitulo;

  ProgressItem({
    required this.id,
    required this.data,
    required this.paginasLidas,
    this.nota,
    required this.livroId,
    this.livroTitulo,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    return ProgressItem(
      id: json['id'] as int,
      data: DateTime.parse(json['data'] as String),
      paginasLidas: json['paginasLidas'] as int,
      nota: json['nota'] as String?,
      livroId: json['livroId'] as int,
      livroTitulo: json['livroTitulo'] as String?,
    );
  }
}

class ReadingSummary {
  final int totalLivros;
  final int livrosConcluidos;
  final int totalPaginasLidas;
  final int livrosEmAndamento;
  final List<ProgressItem> ultimosRegistros;

  ReadingSummary({
    required this.totalLivros,
    required this.livrosConcluidos,
    required this.totalPaginasLidas,
    required this.livrosEmAndamento,
    required this.ultimosRegistros,
  });

  factory ReadingSummary.fromJson(Map<String, dynamic> json) {
    final registros = (json['ultimosRegistros'] as List<dynamic>? ?? [])
        .map((e) => ProgressItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return ReadingSummary(
      totalLivros: json['totalLivros'] as int,
      livrosConcluidos: json['livrosConcluidos'] as int,
      totalPaginasLidas: json['totalPaginasLidas'] as int,
      livrosEmAndamento: json['livrosEmAndamento'] as int,
      ultimosRegistros: registros,
    );
  }
}

class MonthlyReadingStatistics {
  final int mes;
  final int livrosConcluidos;
  final int paginasLidas;

  const MonthlyReadingStatistics({
    required this.mes,
    required this.livrosConcluidos,
    required this.paginasLidas,
  });

  factory MonthlyReadingStatistics.fromJson(Map<String, dynamic> json) {
    return MonthlyReadingStatistics(
      mes: json['mes'] as int,
      livrosConcluidos: json['livrosConcluidos'] as int,
      paginasLidas: (json['paginasLidas'] as num).toInt(),
    );
  }
}

class ReadingActivityDay {
  final DateTime data;
  final int paginasLidas;

  const ReadingActivityDay({required this.data, required this.paginasLidas});

  factory ReadingActivityDay.fromJson(Map<String, dynamic> json) {
    return ReadingActivityDay(
      data: DateTime.parse(json['data'] as String),
      paginasLidas: (json['paginasLidas'] as num).toInt(),
    );
  }
}

class ReadingStatistics {
  final int ano;
  final int livrosConcluidos;
  final int paginasLidas;
  final double mediaDiaria;
  final double mediaPorLivro;
  final int diasDeLeitura;
  final int maiorSequencia;
  final int livrosConcluidosSemData;
  final List<int> anosDisponiveis;
  final List<MonthlyReadingStatistics> meses;
  final List<ReadingActivityDay> atividade;

  const ReadingStatistics({
    required this.ano,
    required this.livrosConcluidos,
    required this.paginasLidas,
    required this.mediaDiaria,
    required this.mediaPorLivro,
    required this.diasDeLeitura,
    required this.maiorSequencia,
    required this.livrosConcluidosSemData,
    required this.anosDisponiveis,
    required this.meses,
    required this.atividade,
  });

  factory ReadingStatistics.fromJson(Map<String, dynamic> json) {
    return ReadingStatistics(
      ano: json['ano'] as int,
      livrosConcluidos: json['livrosConcluidos'] as int,
      paginasLidas: (json['paginasLidas'] as num).toInt(),
      mediaDiaria: (json['mediaDiaria'] as num).toDouble(),
      mediaPorLivro: (json['mediaPorLivro'] as num).toDouble(),
      diasDeLeitura: json['diasDeLeitura'] as int,
      maiorSequencia: json['maiorSequencia'] as int,
      livrosConcluidosSemData: json['livrosConcluidosSemData'] as int,
      anosDisponiveis: (json['anosDisponiveis'] as List<dynamic>)
          .map((year) => year as int)
          .toList(),
      meses: (json['meses'] as List<dynamic>)
          .map(
            (month) => MonthlyReadingStatistics.fromJson(
              month as Map<String, dynamic>,
            ),
          )
          .toList(),
      atividade: (json['atividade'] as List<dynamic>)
          .map(
            (day) => ReadingActivityDay.fromJson(day as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ProgressException implements Exception {
  final String message;
  ProgressException(this.message);

  @override
  String toString() => message;
}

class ProgressService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String? _extractMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<ProgressItem> registrarProgresso({
    required int livroId,
    required int paginasLidas,
    String? nota,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.progresso),
      headers: await _getHeaders(),
      body: jsonEncode({
        'livroId': livroId,
        'paginasLidas': paginasLidas,
        'data': DateTime.now().toUtc().toIso8601String(),
        if (nota != null && nota.isNotEmpty) 'nota': nota,
      }),
    );

    if (response.statusCode == 200) {
      return ProgressItem.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 401) {
      throw ProgressException('Sessão expirada. Faça login novamente.');
    }

    throw ProgressException(
      _extractMessage(response.body) ?? 'Erro ao registrar progresso',
    );
  }

  Future<List<ProgressItem>> getProgressosPorLivro(int livroId) async {
    final response = await http.get(
      Uri.parse(ApiConstants.progressosPorLivro(livroId)),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((json) => ProgressItem.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 401) {
      throw ProgressException('Sessão expirada. Faça login novamente.');
    }

    throw ProgressException(
      _extractMessage(response.body) ?? 'Erro ao carregar histórico',
    );
  }

  Future<ReadingSummary> getResumo() async {
    final response = await http.get(
      Uri.parse(ApiConstants.resumo),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return ReadingSummary.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 401) {
      throw ProgressException('Sessão expirada. Faça login novamente.');
    }

    throw ProgressException(
      _extractMessage(response.body) ?? 'Erro ao carregar resumo',
    );
  }

  Future<ReadingStatistics> getEstatisticas(int ano) async {
    final response = await http.get(
      Uri.parse(ApiConstants.estatisticasLeitura(ano)),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return ReadingStatistics.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 401) {
      throw ProgressException('Sessão expirada. Faça login novamente.');
    }

    throw ProgressException(
      _extractMessage(response.body) ?? 'Erro ao carregar estatísticas',
    );
  }
}
