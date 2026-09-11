import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class LivroException implements Exception {
  final String message;

  LivroException(this.message);
}

class LivroService {
  final _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw LivroException('Sua sessão expirou. Faça login novamente.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> criarLivro({
    required String titulo,
    required String autor,
    required String genero,
    required int totalPaginas,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.livros),
      headers: await _headers(),
      body: jsonEncode({
        'titulo': titulo,
        'autor': autor,
        'genero': genero,
        'totalPaginas': totalPaginas,
      }),
    );

    if (response.statusCode != 201) {
      throw LivroException(
        _messageFrom(response.body) ?? 'Não foi possível salvar o livro.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> listarLivros() async {
    final response = await http.get(
      Uri.parse(ApiConstants.livros),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw LivroException(
        _messageFrom(response.body) ?? 'Não foi possível carregar a estante.',
      );
    }

    return (jsonDecode(response.body) as List)
        .map((livro) => livro as Map<String, dynamic>)
        .toList();
  }

  String? _messageFrom(String body) {
    try {
      return (jsonDecode(body) as Map<String, dynamic>)['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
