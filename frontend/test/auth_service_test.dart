import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('login reports server errors instead of invalid credentials', () async {
    final client = MockClient((request) async => http.Response('', 500));
    addTearDown(client.close);
    final service = AuthService(client: client);

    await expectLater(
      service.login('test@example.com', 'password'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Erro no servidor. Verifique se o servidor e o banco de dados estão funcionando.',
        ),
      ),
    );
  });

  test('login preserves invalid credential responses', () async {
    final client = MockClient(
      (request) async =>
          http.Response('{"message":"Email ou senha inválidos"}', 401),
    );
    addTearDown(client.close);
    final service = AuthService(client: client);

    await expectLater(
      service.login('test@example.com', 'password'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Email ou senha inválidos',
        ),
      ),
    );
  });

  test('login does not label other errors as invalid credentials', () async {
    final client = MockClient((request) async => http.Response('', 400));
    addTearDown(client.close);
    final service = AuthService(client: client);

    await expectLater(
      service.login('test@example.com', 'password'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Não foi possível entrar. Tente novamente.',
        ),
      ),
    );
  });
}
