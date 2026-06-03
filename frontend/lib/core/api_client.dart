import '../utils/session_manager.dart';

/// Cabeceras HTTP comunes (JSON + JWT si hay sesión).
class ApiClient {
  static Map<String, String> jsonHeaders({bool withAuth = true}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final token = SessionManager.token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }
}
