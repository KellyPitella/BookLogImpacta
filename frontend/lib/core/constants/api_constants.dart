import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Porta padrão do backend no launchSettings.json (perfil http).
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5191/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5191/api';
    return 'http://localhost:5191/api';
  }

  static String get login => '$baseUrl/Auth/login';
  static String get register => '$baseUrl/Auth/register';
}
