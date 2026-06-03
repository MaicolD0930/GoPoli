import 'vehiculo.dart';

class Usuario {
  const Usuario({
    required this.idUsuario,
    required this.correo,
    required this.nombre,
    this.tel,
    this.idCarrera,
    this.idTipoUsuario,
    this.idEstado,
    this.nota,
    this.fotoPerfil,
    this.isDriver = false,
    this.vehiculo,
  });

  final int idUsuario;
  final String correo;
  final String nombre;
  final String? tel;
  final int? idCarrera;
  final int? idTipoUsuario;
  final int? idEstado;
  final double? nota;
  final String? fotoPerfil;
  final bool isDriver;
  final Vehiculo? vehiculo;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    Vehiculo? vehiculo;
    if (json['vehiculo'] is Map<String, dynamic>) {
      vehiculo = Vehiculo.fromJson(json['vehiculo'] as Map<String, dynamic>);
    }
    final idTipo = json['idTipoUsuario'] != null
        ? _toInt(json['idTipoUsuario'])
        : null;
    final isDriverJson = json['isDriver'] == true || json['driver'] == true;
    return Usuario(
      idUsuario: _toInt(json['idUsuario']),
      correo: json['correo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      tel: json['tel']?.toString(),
      idCarrera: json['idCarrera'] != null ? _toInt(json['idCarrera']) : null,
      idTipoUsuario: idTipo,
      idEstado: json['idEstado'] != null ? _toInt(json['idEstado']) : null,
      nota: json['nota'] != null ? (json['nota'] as num).toDouble() : null,
      fotoPerfil: json['fotoPerfil']?.toString(),
      isDriver: isDriverJson || idTipo == 2,
      vehiculo: vehiculo,
    );
  }

  Map<String, dynamic> toRegisterJson({
    required String contrasena,
    required int idCarrera,
  }) {
    return {
      'correo': correo.trim(),
      'contrasena': contrasena,
      'nombre': nombre.trim(),
      'tel': tel?.trim(),
      'idCarrera': idCarrera,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nombre': nombre.trim(),
      'tel': tel?.trim(),
      'correo': correo.trim(),
    };
  }

  Usuario copyWith({
    String? nombre,
    String? tel,
    String? correo,
    String? fotoPerfil,
    double? nota,
    int? idTipoUsuario,
    bool? isDriver,
    Vehiculo? vehiculo,
  }) {
    return Usuario(
      idUsuario: idUsuario,
      correo: correo ?? this.correo,
      nombre: nombre ?? this.nombre,
      tel: tel ?? this.tel,
      idCarrera: idCarrera,
      idTipoUsuario: idTipoUsuario ?? this.idTipoUsuario,
      idEstado: idEstado,
      nota: nota ?? this.nota,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      isDriver: isDriver ?? this.isDriver,
      vehiculo: vehiculo ?? this.vehiculo,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
