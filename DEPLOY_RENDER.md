# Deploy GoPoli en Render + Android

## 1) Desplegar backend en Render

### Opción A — Blueprint (recomendado)

1. Sube `render.yaml` a GitHub (rama `jorge` o la que uses).
2. En [Render Dashboard](https://dashboard.render.com/) → **New** → **Blueprint**.
3. Conecta el repo `GoPoli` y la rama con `render.yaml`.
4. Al crear el servicio, pega las variables desde `backend/.env`:
   - `SPRING_DATASOURCE_URL`
   - `SPRING_DATASOURCE_USERNAME`
   - `SPRING_DATASOURCE_PASSWORD`
   - `GOOGLE_MAPS_API_KEY`
5. Espera estado **Live** y prueba: `GET https://TU-SERVICIO.onrender.com/ubicaciones`

### Opción B — Script local

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy-render.ps1
```

Si tienes API key de Render (`RENDER_API_KEY` en `backend/.env`), el script intenta crear el servicio automáticamente.

### Guardar la URL

```powershell
copy render.url.example render.url
# Edita render.url con tu URL real (sin barra final)
```

## 2) Preparar Android (una vez)

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup-android.ps1
```

O doble clic en `INICIAR-ANDROID.bat` (setup + run).

Requisitos en el celular:
- **Opciones de desarrollador** activadas
- **Depuración USB** encendida
- Cable USB al PC (o emulador Android Studio)

## 3) Correr en el celular (backend en Render)

Con el teléfono conectado:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-android.ps1
```

Generar APK para instalar sin cable:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-android.ps1 -BuildApk
```

El APK queda en `frontend/build/app/outputs/flutter-apk/app-release.apk`.

## 4) Variables importantes

| Variable | Dónde |
|----------|--------|
| `API_URL` | `--dart-define=API_URL=https://...onrender.com` |
| Maps Android | `frontend/lib/config/google_maps_config.dart` |
| BD | Neon (misma que local, vía env en Render) |

## 5) Notas

- El plan **free** de Render duerme tras inactividad; la primera petición puede tardar ~30 s.
- CORS ya está abierto en los controllers (`@CrossOrigin("*")`).
- No subas `backend/.env` ni `render.url` a git.
