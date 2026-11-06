import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final http.Client? _client;

  AuthService({http.Client? client}) : _client = client;

  Future<AuthResponseModel> login(String email, String senha) async {
    final uri = Uri.parse(ApiConstants.login);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'senha': senha});
    final response = _client == null
        ? await http.post(uri, headers: headers, body: body)
        : await _client.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final auth = AuthResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _saveAuth(auth);
      return auth;
    }

    if (response.statusCode >= 500) {
      throw AuthException(
        'Erro no servidor. Verifique se o servidor e o banco de dados estão funcionando.',
      );
    }

    final message =
        _extractMessage(response.body) ??
        (response.statusCode == 401
            ? 'Email ou senha inválidos'
            : 'Não foi possível entrar. Tente novamente.');
    throw AuthException(message);
  }

  Future<AuthResponseModel> register(
    String nome,
    String email,
    String senha,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final auth = AuthResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _saveAuth(auth);
      return auth;
    }

    final message =
        _extractMessage(response.body) ?? 'Não foi possível criar a conta';
    throw AuthException(message);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> _saveAuth(AuthResponseModel auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, auth.token);
    await prefs.setString(_userKey, jsonEncode(auth.usuario.toJson()));
  }

  String? _extractMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
