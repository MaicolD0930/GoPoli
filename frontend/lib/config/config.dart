import 'google_maps_config.dart';

class Config {
  // Permite cambiar backend por entorno sin editar codigo:
  // flutter run --dart-define=API_URL=https://tu-backend.up.railway.app
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: "http://192.168.1.16:8080",
  );

  /// Misma clave que en [kGoogleMapsApiKey] (un solo lugar para editar).
  static String get googleMapsApiKey => kGoogleMapsApiKey;
}
