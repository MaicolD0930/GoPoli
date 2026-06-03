class HistorialViaje {
  const HistorialViaje({
    required this.idServicio,
    this.fecha,
    this.horaSalida,
    this.descripcion,
    this.tripType,
    this.tripTypeLabel,
    this.nombreSalida,
    this.nombreLlegada,
    this.miRolParticipacionLabel,
    required this.participantes,
  });

  final int idServicio;
  final String? fecha;
  final String? horaSalida;
  final String? descripcion;
  final String? tripType;
  final String? tripTypeLabel;
  final String? nombreSalida;
  final String? nombreLlegada;
  final String? miRolParticipacionLabel;
  final List<ParticipanteHistorial> participantes;

  factory HistorialViaje.fromJson(Map<String, dynamic> json) {
    final parts = json['participantes'];
    return HistorialViaje(
      idServicio: _toInt(json['idServicio']),
      fecha: json['fecha']?.toString(),
      horaSalida: json['horaSalida']?.toString(),
      descripcion: json['descripcion']?.toString(),
      tripType: json['tripType']?.toString(),
      tripTypeLabel: json['tripTypeLabel']?.toString(),
      nombreSalida: json['nombreSalida']?.toString(),
      nombreLlegada: json['nombreLlegada']?.toString(),
      miRolParticipacionLabel: json['miRolParticipacionLabel']?.toString(),
      participantes: parts is List
          ? parts
              .map((e) => ParticipanteHistorial.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList()
          : [],
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class ParticipanteHistorial {
  const ParticipanteHistorial({
    required this.nombreUsuario,
    required this.rolParticipacionLabel,
  });

  final String nombreUsuario;
  final String rolParticipacionLabel;

  factory ParticipanteHistorial.fromJson(Map<String, dynamic> json) {
    return ParticipanteHistorial(
      nombreUsuario: json['nombreUsuario']?.toString() ?? 'Usuario',
      rolParticipacionLabel:
          json['rolParticipacionLabel']?.toString() ?? 'Pasajero',
    );
  }
}
