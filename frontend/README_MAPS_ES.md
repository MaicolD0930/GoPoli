# Google Maps: qué es la “API key” y cómo sacarla

La **API key** (clave de API) es un **código largo** que Google te da para decir: “esta app puede usar mapas y rutas de mi cuenta”. No es tu contraseña de Gmail; es solo para el proyecto.

## Pasos (unos 5 minutos)

1. Entra a **[Google Cloud Console](https://console.cloud.google.com/)** con tu cuenta Google.
2. Arriba, elige **Crear proyecto** (o selecciona uno que ya tengas).
3. Menú ☰ → **APIs y servicios** → **Biblioteca**.
4. Busca y pulsa **Activar** en:
   - **Maps SDK for Android**
   - **Directions API**
5. Menú **Credenciales** → **+ Crear credenciales** → **Clave de API**.
6. Copia la clave (normalmente empieza por `AIza...`).
7. En tu PC, crea el archivo local (no se sube a Git):
   - Copia `frontend/lib/config/google_maps_config.example.dart` a `frontend/lib/config/google_maps_config.dart` (mismo nombre sin `.example`).
8. Abre `google_maps_config.dart` y pega la clave **entre las comillas** de `kGoogleMapsApiKey`, por ejemplo:
   - `const String kGoogleMapsApiKey = 'AIzaSy...';`
9. Guarda el archivo y vuelve a ejecutar la app (`flutter run`). **No hagas commit de `google_maps_config.dart`** (ya está en `.gitignore`).

Android toma la **misma** clave al compilar (no hace falta pegarla en otro sitio). Si más adelante usas **iOS**, copia la misma clave en `ios/Runner/Info.plist` en `GMSApiKey`.

## Si no pones clave

El mapa puede verse gris o sin ruta por carretera; la app intentará al menos una línea recta entre los puntos que tengan coordenadas en la base de datos.

## Facturación

Google suele pedir **activar facturación** en el proyecto para usar Maps, pero hay **uso gratuito mensual**; revisa la página oficial de precios de Google Maps Platform.
