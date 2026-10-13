import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5191/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5191/api';
    return 'http://localhost:5191/api';
  }

  static String get login => '$baseUrl/Auth/login';
  static String get register => '$baseUrl/Auth/register';
  static String get livros => '$baseUrl/Livros';
  static String livro(int id) => '$baseUrl/Livros/$id';
  static String capaLivro(int livroId) => '$baseUrl/Livros/$livroId/capa';

  static String get progresso => '$baseUrl/Progresso';
  static String progressosPorLivro(int livroId) =>
      '$baseUrl/Progresso/livro/$livroId';
  static String get resumo => '$baseUrl/Progresso/resumo';
}
