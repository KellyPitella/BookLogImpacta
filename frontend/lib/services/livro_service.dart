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
  LivroService({http.Client? client, AuthService? authService})
    : _client = client,
      _authService = authService ?? AuthService();

  final http.Client? _client;
  final AuthService _authService;

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

  Future<List<Map<String, dynamic>>> listarLivros({
    String? status,
    bool? favoritos,
  }) async {
    final params = <String, String>{
      'status': ?status,
      if (favoritos != null) 'favoritos': favoritos.toString(),
    };
    final baseUri = Uri.parse(ApiConstants.livros);
    final uri = params.isEmpty
        ? baseUri
        : baseUri.replace(queryParameters: params);
    final headers = await _headers();
    final response = _client == null
        ? await http.get(uri, headers: headers)
        : await _client.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw LivroException(
        _messageFrom(response.body) ?? 'Não foi possível carregar a estante.',
      );
    }

    return (jsonDecode(response.body) as List)
        .map((livro) => livro as Map<String, dynamic>)
        .toList();
  }

  Future<bool> toggleFavorito(int livroId) async {
    final uri = Uri.parse('${ApiConstants.livro(livroId)}/favorito');
    final headers = await _headers();
    final response = _client == null
        ? await http.patch(uri, headers: headers)
        : await _client.patch(uri, headers: headers);
    if (response.statusCode != 200) {
      throw LivroException(
        _messageFrom(response.body) ?? 'Não foi possível atualizar favoritos.',
      );
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['favorito']
        as bool;
  }

  Future<void> atualizarStatus(int livroId, String novoStatus) async {
    final uri = Uri.parse('${ApiConstants.livro(livroId)}/status');
    final headers = await _headers();
    final body = jsonEncode({'status': novoStatus});
    final response = _client == null
        ? await http.patch(uri, headers: headers, body: body)
        : await _client.patch(uri, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw LivroException(
        _messageFrom(response.body) ?? 'Não foi possível atualizar o status.',
      );
    }
  }

  String? _messageFrom(String body) {
    try {
      return (jsonDecode(body) as Map<String, dynamic>)['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
