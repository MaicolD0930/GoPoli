/// Errores de validación por campo devueltos por el backend (mapa JSON).
class FieldValidationException implements Exception {
  FieldValidationException(this.fieldErrors);

  final Map<String, String> fieldErrors;

  @override
  String toString() => fieldErrors.values.join('\n');
}
