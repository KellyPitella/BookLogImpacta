import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/book_model.dart';
import 'package:frontend/services/livro_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'auth_token': 'test-token'});
  });

  test('book model decodes defaults and round-trips status and favorite', () {
    final json = <String, dynamic>{
      'id': 1,
      'titulo': 'Livro',
      'totalPaginas': 100,
      'paginasLidas': 0,
      'concluido': false,
      'dataCadastro': '2026-01-01T00:00:00Z',
      'percentual': 0,
    };
    final book = BookModel.fromJson(json);
    expect(book.favorito, isFalse);
    expect(book.status, 'QueroLer');
    final updated = book.copyWith(favorito: true, status: 'Lido');
    expect(BookModel.fromJson(updated.toJson()).favorito, isTrue);
    expect(BookModel.fromJson(updated.toJson()).status, 'Lido');
    expect(updated.copyWith().favorito, isTrue);
    expect(updated.copyWith().status, 'Lido');
  });

  test('GET sends encoded optional filters and bearer token', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response('[]', 200);
    });
    addTearDown(client.close);
    final service = LivroService(client: client);
    await service.listarLivros(status: 'Quero Ler', favoritos: false);
    await service.listarLivros(favoritos: true);
    await service.listarLivros();
    expect(requests[0].method, 'GET');
    expect(requests[0].url.path, '/api/Livros');
    expect(requests[0].url.queryParameters, {
      'status': 'Quero Ler',
      'favoritos': 'false',
    });
    expect(requests[0].headers['Authorization'], 'Bearer test-token');
    expect(requests[1].url.queryParameters, {'favoritos': 'true'});
    expect(requests[2].url.hasQuery, isFalse);
  });

  test('PATCH sends JWT and reads the server favorite response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(request.url.path, '/api/Livros/12/favorito');
      expect(request.headers['Authorization'], 'Bearer test-token');
      return http.Response('{"favorito":true}', 200);
    });
    addTearDown(client.close);
    expect(await LivroService(client: client).toggleFavorito(12), isTrue);
  });

  test('PATCH sends status as JSON with JWT', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(request.url.path, '/api/Livros/12/status');
      expect(request.headers['Authorization'], 'Bearer test-token');
      expect(request.headers['Content-Type'], 'application/json');
      expect(jsonDecode(request.body), {'status': 'Lido'});
      return http.Response('{"status":"Lido"}', 200);
    });
    addTearDown(client.close);
    await LivroService(client: client).atualizarStatus(12, 'Lido');
  });

  test(
    'request errors and malformed successful responses are not hidden',
    () async {
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/favorito')) {
          return http.Response('{}', 200);
        }
        return http.Response('{"message":"Status inválido"}', 400);
      });
      addTearDown(client.close);
      final service = LivroService(client: client);
      await expectLater(service.toggleFavorito(1), throwsA(isA<TypeError>()));
      await expectLater(
        service.atualizarStatus(1, 'erro'),
        throwsA(
          isA<LivroException>().having(
            (e) => e.message,
            'message',
            'Status inválido',
          ),
        ),
      );
      await expectLater(service.listarLivros(), throwsA(isA<LivroException>()));
    },
  );
}
