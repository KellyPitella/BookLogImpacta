import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/book_model.dart';
import 'auth_service.dart';

class LivroException implements Exception {
  final String message;

  LivroException(this.message);
}

class LivroService {
  final _authService = AuthService();

  Future<Uint8List?> downloadCapa(int livroId) async {
    final response = await http.get(
      Uri.parse(ApiConstants.capaLivro(livroId)),
      headers: await _headers(),
    );

    if (response.statusCode != 200) return null;
    return response.bodyBytes;
  }

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

  Future<BookModel> atualizarLivro({
    required int livroId,
    required String titulo,
    required String autor,
    required String genero,
    required int totalPaginas,
  }) async {
    final response = await http.put(
      Uri.parse(ApiConstants.livro(livroId)),
      headers: await _headers(),
      body: jsonEncode({
        'titulo': titulo,
        'autor': autor.isEmpty ? null : autor,
        'genero': genero.isEmpty ? null : genero,
        'totalPaginas': totalPaginas,
      }),
    );

    if (response.statusCode != 200) {
      throw LivroException(
        _messageFrom(response.body) ?? 'Não foi possível atualizar o livro.',
      );
    }

    return BookModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deletarLivro(int livroId) async {
    final response = await http.delete(
      Uri.parse(ApiConstants.livro(livroId)),
      headers: await _headers(),
    );

    if (response.statusCode != 204) {
      throw LivroException(
        _messageFrom(response.body) ?? 'Não foi possível excluir o livro.',
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
