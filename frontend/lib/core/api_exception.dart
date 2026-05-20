import 'dart:convert';

/// Error devuelto por el backend o por fallo de red.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromResponse(int statusCode, String body) {
    var msg = body.trim();
    if (msg.isEmpty) {
      msg = _defaultMessage(statusCode);
    } else {
      try {
        final decoded = jsonDecode(msg);
        if (decoded is Map && decoded['message'] != null) {
          msg = decoded['message'].toString();
        } else if (decoded is String) {
          msg = decoded;
        }
      } catch (_) {
        // body en texto plano (Spring devuelve string directo)
      }
    }
    return ApiException(msg, statusCode: statusCode);
  }

  static String _defaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Datos inválidos. Revisa el formulario.';
      case 409:
        return 'El correo ya está registrado.';
      case 401:
        return 'Credenciales incorrectas.';
      default:
        return 'Error del servidor ($statusCode).';
    }
  }

  @override
  String toString() => message;
}
