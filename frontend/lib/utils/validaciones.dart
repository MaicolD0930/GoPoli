class Validaciones {
  static final RegExp _emailBasico = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Correo institucional Poli (reglas de negocio GoPoli).
  static bool correoInstitucional(String correo) {
    final c = correo.trim().toLowerCase();
    return _emailBasico.hasMatch(c) && c.endsWith('@elpoli.edu.co');
  }

  static String? mensajeCorreo(String correo) {
    final c = correo.trim();
    if (c.isEmpty) return 'El correo es obligatorio';
    if (!_emailBasico.hasMatch(c)) return 'Ingresa un correo válido';
    if (!c.toLowerCase().endsWith('@elpoli.edu.co')) {
      return 'Usa tu correo @elpoli.edu.co';
    }
    return null;
  }

  static bool contrasenaValida(String pass) {
    return pass.length >= 8;
  }

  static String? mensajeContrasena(String pass) {
    if (pass.isEmpty) return 'La contraseña es obligatoria';
    if (pass.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    return null;
  }

  static bool contrasenasCoinciden(String pass, String confirmacion) {
    return pass == confirmacion;
  }

  static String? mensajeConfirmacion(String pass, String confirmacion) {
    if (confirmacion.isEmpty) return 'Confirma tu contraseña';
    if (pass != confirmacion) return 'Las contraseñas no coinciden';
    return null;
  }

  static bool nombreValido(String nombre) {
    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]{2,}$').hasMatch(nombre.trim());
  }

  static String? mensajeNombre(String nombre) {
    final n = nombre.trim();
    if (n.isEmpty) return 'El nombre es obligatorio';
    if (!nombreValido(n)) {
      return 'Solo letras y espacios (mín. 2 caracteres)';
    }
    return null;
  }

  static bool telefonoValido(String telefono) {
    return RegExp(r'^[0-9]{8,14}$').hasMatch(telefono.trim());
  }

  static String? mensajeTelefono(String telefono) {
    final t = telefono.trim();
    if (t.isEmpty) return 'El teléfono es obligatorio';
    if (!telefonoValido(t)) {
      return 'Entre 8 y 14 dígitos numéricos';
    }
    return null;
  }
}
