import 'google_maps_config.dart';

class Config {
  static const String apiUrl = "http://192.168.1.106:8080";

  /// Misma clave que en [kGoogleMapsApiKey] (un solo lugar para editar).
  static String get googleMapsApiKey => kGoogleMapsApiKey;
}
