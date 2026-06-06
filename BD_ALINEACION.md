# Alineación código ↔ base de datos (solo revisión)

Referencia de cómo el backend JPA y el frontend usan el esquema Neon **sin modificar tablas**. Constantes en [`GoPoliConstants.java`](backend/src/main/java/com/proyect/gopoli/model/GoPoliConstants.java).

## Tablas mapeadas y uso

| Tabla | Columnas clave | Uso en la app |
|-------|----------------|---------------|
| `usuario` | `id_tipousuario`, `id_estado`, `nota`, `id_carrera` | Auth, perfil, rol pasajero/conductor |
| `tipo_usuario` | `id_tipousuario`, `nombre_tipousuario` | Catálogo: `1` Pasajero, `2` Conductor (FK lógica) |
| `vehiculo` | `id_usuario`, `marca`, `modelo`, `matricula`, `color` | Obligatorio al ser conductor (`register-driver`) |
| `carrera` | `id_carrera` | Dropdown en registro |
| `ubicacion` | coordenadas, `nombre_ubicacion` | Mapa, crear viaje, rutas |
| `servicio` | `id_tiposervicio`, `id_estado_servicio`, `id_creador` | Viajes compartidos |
| `servicio_usuario` | `rol`, `rol_participacion` | Miembros del grupo |

## Valores de negocio (código)

### Tipo de usuario (`usuario.id_tipousuario`)

| ID | Rol | Cómo se asigna |
|----|-----|----------------|
| 1 | Pasajero | `POST /register` (siempre) |
| 2 | Conductor | `POST /usuario/me/register-driver` + fila en `vehiculo` |

Vuelta a pasajero: `POST /usuario/me/unregister-driver` (elimina vehículo).

### Tipo de servicio (`servicio.id_tiposervicio`)

| ID | Significado |
|----|-------------|
| 1 | Grupo de viaje (pasajeros) |
| 3 | Grupo conductor |

Solo usuarios con `id_tipousuario = 2` pueden crear tipo 3.

### Estado de servicio (`servicio.id_estado_servicio`)

| ID | Estado |
|----|--------|
| 1 | Activo |
| 2 | Cancelado |
| 3 | Finalizado |
| 4 | En curso |

### Participación en viaje (`servicio_usuario.rol_participacion`)

| Valor | Etiqueta UI |
|-------|-------------|
| `passenger` | Pasajero |
| `driver` | Conductor |

### Calificaciones (`usuario.nota`)

- Tipo JPA: `Double`
- Se actualiza con `POST /usuario/{id}/calificar` (requiere `idServicio` y viaje finalizado)
- Si Neon tiene `nota` como texto, corregir manualmente con [`fix_usuario_nota_column.sql`](backend/scripts/fix_usuario_nota_column.sql) (fuera del flujo normal de deploy)

## Tablas de catálogo no expuestas al frontend

Existen en BD pero no tienen endpoints dedicados: `tipo_servicio`, `estado_servicio`, `tipo_vehiculo`, `estado_usuario`. El código usa constantes en lugar de consultar esas tablas.

## Flujo conductor vs pasajero

```
Registro → id_tipousuario=1 (pasajero)
    ↓
Login → JWT + UsuarioDto (con vehículo si es conductor)
    ↓
[Opcional] register-driver → id_tipousuario=2 + vehiculo
    ↓
Crear viaje: tipo 1 (todos) o tipo 3 (solo conductor)
```
