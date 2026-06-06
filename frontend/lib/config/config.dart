import 'google_maps_config.dart';

class Config {
  // Permite cambiar backend por entorno sin editar codigo:
  // flutter run --dart-define=API_URL=https://gopoli.onrender.com
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://gopoli.onrender.com',
  );

  /// Render free tarda ~30-90 s en despertar tras inactividad.
  static const Duration apiTimeout = Duration(seconds: 90);

  /// Misma clave que en [kGoogleMapsApiKey] (un solo lugar para editar).
  static String get googleMapsApiKey => kGoogleMapsApiKey;
}
