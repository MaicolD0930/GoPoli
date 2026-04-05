class SessionManager {
  static int? idUsuario;
  static String? nombre;
  static String? correo;
  static int? idTipoUsuario;

  static void iniciarSesion(
    dynamic idUsuarioRaw,
    String nombreUsuario,
    String correoUsuario,
    dynamic tipoUsuarioRaw,
  ) {
    idUsuario = idUsuarioRaw is num
        ? idUsuarioRaw.toInt()
        : int.tryParse(idUsuarioRaw.toString());
    nombre = nombreUsuario;
    correo = correoUsuario;
    idTipoUsuario = tipoUsuarioRaw is num
        ? tipoUsuarioRaw.toInt()
        : int.tryParse(tipoUsuarioRaw.toString());
  }

  static void cerrarSesion() {
    idUsuario = null;
    nombre = null;
    correo = null;
    idTipoUsuario = null;
  }

  /// Etiqueta legible según [idTipoUsuario] del backend (1 = pasajero por defecto al registrar).
  static String etiquetaTipoUsuario() {
    switch (idTipoUsuario) {
      case 2:
        return 'Chofer';
      case 1:
      default:
        return 'Pasajero';
    }
  }
}
