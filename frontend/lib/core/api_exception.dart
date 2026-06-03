import 'dart:convert';

import 'field_validation_exception.dart';

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
        if (decoded is Map) {
          if (decoded['message'] != null) {
            msg = decoded['message'].toString();
          } else if (_esMapaErroresCampo(decoded)) {
            throw FieldValidationException(
              decoded.map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              ),
            );
          }
        } else if (decoded is String) {
          msg = decoded;
        }
      } catch (e) {
        if (e is FieldValidationException) rethrow;
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

  static bool _esMapaErroresCampo(Map decoded) {
    const campos = {'marca', 'modelo', 'color', 'placa'};
    return decoded.keys.any((k) => campos.contains(k.toString()));
  }

  @override
  String toString() => message;
}
