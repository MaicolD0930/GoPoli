import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/historial_viaje.dart';
import '../models/usuario.dart';
import '../utils/session_manager.dart';

class UsuarioService {
  const UsuarioService();

  Future<Usuario> obtenerPerfil() async {
    return _request(
      () => http.get(
        Uri.parse('${Config.apiUrl}/usuario/me'),
        headers: ApiClient.jsonHeaders(),
      ),
    );
  }

  Future<Usuario> actualizarPerfil({
    required String nombre,
    required String telefono,
    required String correo,
  }) async {
    final u = await _request(
      () => http.put(
        Uri.parse('${Config.apiUrl}/usuario/me'),
        headers: ApiClient.jsonHeaders(),
        body: jsonEncode({
          'nombre': nombre,
          'tel': telefono,
          'correo': correo,
        }),
      ),
    );
    await SessionManager.actualizarUsuario(u);
    return u;
  }

  Future<Usuario> subirFotoPerfil(String fotoBase64) async {
    final u = await _request(
      () => http.put(
        Uri.parse('${Config.apiUrl}/usuario/me/foto'),
        headers: ApiClient.jsonHeaders(),
        body: jsonEncode({'fotoBase64': fotoBase64}),
      ),
    );
    await SessionManager.actualizarUsuario(u);
    return u;
  }

  Future<Usuario> registerAsDriver({
    required String marca,
    required String modelo,
    required String color,
    required String placa,
  }) async {
    final u = await _request(
      () => http.post(
        Uri.parse('${Config.apiUrl}/usuario/me/register-driver'),
        headers: ApiClient.jsonHeaders(),
        body: jsonEncode({
          'marca': marca.trim(),
          'modelo': modelo.trim(),
          'color': color.trim(),
          'placa': placa.trim().toUpperCase(),
        }),
      ),
    );
    await SessionManager.actualizarUsuario(u);
    return u;
  }

  Future<Usuario> unregisterAsDriver() async {
    final u = await _request(
      () => http.post(
        Uri.parse('${Config.apiUrl}/usuario/me/unregister-driver'),
        headers: ApiClient.jsonHeaders(),
      ),
    );
    await SessionManager.actualizarUsuario(u);
    return u;
  }

  Future<List<HistorialViaje>> obtenerHistorialViajes() async {
    try {
      final response = await http
          .get(
            Uri.parse('${Config.apiUrl}/usuario/me/historial-viajes'),
            headers: ApiClient.jsonHeaders(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => HistorialViaje.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Error de conexión con el servidor');
    }
  }

  Future<void> inhabilitarCuenta() async {
    final response = await http
        .post(
          Uri.parse('${Config.apiUrl}/usuario/me/inhabilitar'),
          headers: ApiClient.jsonHeaders(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
    await SessionManager.cerrarSesion();
  }

  Future<void> eliminarCuenta() async {
    final response = await http
        .delete(
          Uri.parse('${Config.apiUrl}/usuario/me'),
          headers: ApiClient.jsonHeaders(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
    await SessionManager.cerrarSesion();
  }

  Future<Usuario> _request(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return Usuario.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Error de conexión con el servidor');
    }
  }
}
