import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/usuario.dart';

/// Sesión en memoria + almacenamiento seguro del JWT (HU-02).
class SessionManager {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'gopoli_jwt';
  static const _keyId = 'gopoli_id_usuario';
  static const _keyNombre = 'gopoli_nombre';
  static const _keyCorreo = 'gopoli_correo';
  static const _keyTipo = 'gopoli_tipo_usuario';
  static const _keyNota = 'gopoli_nota';
  static const _keyFoto = 'gopoli_foto';

  static String? token;
  static int? idUsuario;
  static String? nombre;
  static String? correo;
  static int? idTipoUsuario;
  static double? nota;
  static String? fotoPerfil;

  static bool get haySesion =>
      token != null && token!.isNotEmpty && idUsuario != null;

  static bool get esConductor => idTipoUsuario == 2;

  static Future<void> iniciarSesion(LoginSessionData data) async {
    token = data.token;
    idUsuario = data.usuario.idUsuario;
    nombre = data.usuario.nombre;
    correo = data.usuario.correo;
    idTipoUsuario = data.usuario.idTipoUsuario;
    nota = data.usuario.nota;
    fotoPerfil = data.usuario.fotoPerfil;

    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyId, value: idUsuario.toString());
    await _storage.write(key: _keyNombre, value: nombre);
    await _storage.write(key: _keyCorreo, value: correo);
    if (idTipoUsuario != null) {
      await _storage.write(key: _keyTipo, value: idTipoUsuario.toString());
    }
    if (nota != null) {
      await _storage.write(key: _keyNota, value: nota.toString());
    }
    if (fotoPerfil != null) {
      await _storage.write(key: _keyFoto, value: fotoPerfil);
    }
  }

  static Future<void> actualizarUsuario(Usuario u) async {
    nombre = u.nombre;
    correo = u.correo;
    nota = u.nota;
    fotoPerfil = u.fotoPerfil;
    if (u.idTipoUsuario != null) {
      idTipoUsuario = u.idTipoUsuario;
      await _storage.write(key: _keyTipo, value: idTipoUsuario.toString());
    }
    await _storage.write(key: _keyNombre, value: nombre);
    await _storage.write(key: _keyCorreo, value: correo);
    if (nota != null) {
      await _storage.write(key: _keyNota, value: nota.toString());
    }
    if (fotoPerfil != null) {
      await _storage.write(key: _keyFoto, value: fotoPerfil);
    } else {
      await _storage.delete(key: _keyFoto);
    }
  }

  static Future<bool> cargarSesion() async {
    final t = await _storage.read(key: _keyToken);
    final id = await _storage.read(key: _keyId);
    if (t == null || t.isEmpty || id == null) return false;

    token = t;
    idUsuario = int.tryParse(id);
    nombre = await _storage.read(key: _keyNombre);
    correo = await _storage.read(key: _keyCorreo);
    final tipo = await _storage.read(key: _keyTipo);
    idTipoUsuario = tipo != null ? int.tryParse(tipo) : null;
    final notaStr = await _storage.read(key: _keyNota);
    nota = notaStr != null ? double.tryParse(notaStr) : null;
    fotoPerfil = await _storage.read(key: _keyFoto);
    return haySesion;
  }

  static Future<void> cerrarSesion() async {
    token = null;
    idUsuario = null;
    nombre = null;
    correo = null;
    idTipoUsuario = null;
    nota = null;
    fotoPerfil = null;
    await _storage.deleteAll();
  }

  static String etiquetaTipoUsuario() {
    if (esConductor) return 'Conductor';
    return 'Pasajero';
  }
}

class LoginSessionData {
  const LoginSessionData({required this.token, required this.usuario});

  final String token;
  final Usuario usuario;
}
