class SessionManager {
  static int? idUsuario;
  static String? nombre;
  static String? correo;
  static int? idTipoUsuario;

  static void iniciarSesion(
    int id,
    String nombreUsuario,
    String correoUsuario,
    int tipoUsuario,
  ) {
    idUsuario = id;
    nombre = nombreUsuario;
    correo = correoUsuario;
    idTipoUsuario = tipoUsuario;
  }

  static void cerrarSesion() {
    idUsuario = null;
    nombre = null;
    correo = null;
    idTipoUsuario = null;
  }
}
