import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';

/// Ruta por carretera vía backend (Google Directions). Evita CORS en Flutter Web.
class RouteService {
  static Future<List<LatLng>> rutaEntre(LatLng origen, LatLng destino) async {
    try {
      final uri = Uri.parse('${Config.apiUrl}/ruta/direcciones').replace(
        queryParameters: {
          'origenLat': origen.latitude.toString(),
          'origenLng': origen.longitude.toString(),
          'destinoLat': destino.latitude.toString(),
          'destinoLng': destino.longitude.toString(),
          'mode': 'driving',
        },
      );

      final res = await http.get(uri).timeout(Config.apiTimeout);
      if (res.statusCode != 200) {
        return [origen, destino];
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final puntos = data['puntos'] as List<dynamic>?;
      if (puntos == null || puntos.length < 2) {
        return [origen, destino];
      }

      return puntos.map((p) {
        final m = p as Map<String, dynamic>;
        return LatLng(
          (m['lat'] as num).toDouble(),
          (m['lng'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return [origen, destino];
    }
  }
}
