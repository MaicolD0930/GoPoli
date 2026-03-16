class validaciones {
  static bool correoInstitucional(String correo) {
    return correo.trim().endsWith("@elpoli.edu.co");
  }

  static bool contrasenaValida(String pass) {
    return pass.trim().length >= 8;
  }

  static bool nombreValido(String nombre) {
    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$').hasMatch(nombre.trim());
  }

  static bool documentoValido(String documento) {
    return RegExp(r'^[0-9]+$').hasMatch(documento.trim());
  }

  static bool telefonoValido(String telefono) {
    return RegExp(r'^[0-9]{8,14}$').hasMatch(telefono.trim());
  }
}
