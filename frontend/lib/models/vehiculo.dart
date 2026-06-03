class Vehiculo {
  const Vehiculo({
    this.idVehiculo,
    required this.marca,
    required this.modelo,
    required this.color,
    required this.placa,
  });

  final int? idVehiculo;
  final String marca;
  final String modelo;
  final String color;
  final String placa;

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      idVehiculo: json['idVehiculo'] != null ? _toInt(json['idVehiculo']) : null,
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      placa: json['placa']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
