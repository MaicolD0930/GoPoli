class Carrera {
  const Carrera({required this.idCarrera, required this.nombreCarrera});

  final int idCarrera;
  final String nombreCarrera;

  factory Carrera.fromJson(Map<String, dynamic> json) {
    return Carrera(
      idCarrera: _toInt(json['idCarrera']),
      nombreCarrera: json['nombreCarrera']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
