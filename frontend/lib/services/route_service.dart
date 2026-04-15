import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/config.dart';

/// Ruta por carretera (Directions) entre dos puntos de la BD; si no hay clave o falla la API, línea recta.
class RouteService {
  static Future<List<LatLng>> rutaEntre(LatLng origen, LatLng destino) async {
    final key = Config.googleMapsApiKey.trim();
    if (key.isEmpty || key == 'YOUR_GOOGLE_MAPS_API_KEY') {
      return [origen, destino];
    }
    try {
      // TODO: migrar a la API nueva de flutter_polyline_points.
      // ignore: deprecated_member_use
      final poly = PolylinePoints.legacy(key);
      final res = await poly.getRouteBetweenCoordinates(
        // ignore: deprecated_member_use
        request: PolylineRequest(
          origin: PointLatLng(origen.latitude, origen.longitude),
          destination: PointLatLng(destino.latitude, destino.longitude),
          mode: TravelMode.driving,
        ),
      );
      if (res.points.isEmpty) return [origen, destino];
      return res.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
    } catch (_) {
      return [origen, destino];
    }
  }
}
