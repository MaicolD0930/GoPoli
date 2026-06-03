class VehicleValidators {
  static String? marca(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'La marca es obligatoria';
    if (v.length < 2) return 'Mínimo 2 caracteres';
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$').hasMatch(v)) {
      return 'Solo letras y espacios';
    }
    return null;
  }

  static String? modelo(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El modelo es obligatorio';
    if (v.length < 2) return 'Mínimo 2 caracteres';
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ0-9 ]+$').hasMatch(v)) {
      return 'Solo letras, números y espacios';
    }
    return null;
  }

  static String? color(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El color es obligatorio';
    if (v.length < 3) return 'Mínimo 3 caracteres';
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$').hasMatch(v)) {
      return 'Solo letras y espacios';
    }
    return null;
  }

  static String? placa(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return 'La placa es obligatoria';
    if (v.length < 5 || v.length > 8) {
      return 'Entre 5 y 8 caracteres alfanuméricos';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(v)) {
      return 'Solo letras y números';
    }
    return null;
  }
}
