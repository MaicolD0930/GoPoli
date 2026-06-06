import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/login_response.dart';
import '../models/usuario.dart';
import '../utils/session_manager.dart';

class AuthService {
  const AuthService();

  Future<Usuario> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
    required String telefono,
    required int idCarrera,
  }) async {
    final usuario = Usuario(
      idUsuario: 0,
      correo: correo,
      nombre: nombre,
      tel: telefono,
      idCarrera: idCarrera,
    );

    try {
      final response = await http
          .post(
            Uri.parse('${Config.apiUrl}/register'),
            headers: ApiClient.jsonHeaders(withAuth: false),
            body: jsonEncode(
              usuario.toRegisterJson(
                contrasena: contrasena,
                idCarrera: idCarrera,
              ),
            ),
          )
          .timeout(Config.apiTimeout);

      if (response.statusCode == 200) {
        return Usuario.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'No se pudo conectar con el servidor (${Config.apiUrl})',
      );
    }
  }

  /// POST /login — HU-02 con JWT.
  Future<LoginResponse> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Config.apiUrl}/login'),
            headers: ApiClient.jsonHeaders(withAuth: false),
            body: jsonEncode({
              'correo': correo.trim(),
              'contrasena': contrasena,
            }),
          )
          .timeout(Config.apiTimeout);

      if (response.statusCode == 200) {
        final login = LoginResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await SessionManager.iniciarSesion(
          LoginSessionData(token: login.token, usuario: login.usuario),
        );
        return login;
      }
      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'No se pudo conectar con el servidor (${Config.apiUrl})',
      );
    }
  }
}
