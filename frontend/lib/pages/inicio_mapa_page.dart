import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/config.dart';
import '../services/route_service.dart';
import '../utils/session_manager.dart';
import '../widgets/crear_servicio_form.dart';
import 'grupo_page.dart';

int? _parseUbicacionId(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? _parseCoord(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

/// Mapa Google + ruta según ubicaciones (lat/long en BD) + crear servicio.
class InicioMapaPage extends StatefulWidget {
  const InicioMapaPage({
    super.key,
    this.shellRefreshTick,
    this.viajeEnMapaNotifier,
  });

  /// Al incrementar (p. ej. al volver de [GrupoPage]), recarga estado de servicio activo.
  final ValueNotifier<int>? shellRefreshTick;

  /// Al asignar un [idServicio], se dibuja su ruta y se limpia el valor (desde otras pestañas).
  final ValueNotifier<int?>? viajeEnMapaNotifier;

  @override
  State<InicioMapaPage> createState() => _InicioMapaPageState();
}

class _InicioMapaPageState extends State<InicioMapaPage> {
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);

  static const LatLng _centroMedellin = LatLng(6.2476, -75.5658);

  final _destinoQuery = ValueNotifier<String>('');
  final _busquedaController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();

  int? _idServicioActivo;
  int? _idServicioEnCurso;

  /// La polilínea verde corresponde al viaje en curso (no al borrador del formulario).
  bool _modoRutaViajeEnCurso = false;

  List<LatLng> _puntosRuta = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _busquedaController.addListener(() {
      _destinoQuery.value = _busquedaController.text;
    });
    widget.shellRefreshTick?.addListener(_onShellRefresh);
    widget.viajeEnMapaNotifier?.addListener(_onViajeEnMapaSolicitado);
    _cargarEstadoServicios();
  }

  @override
  void dispose() {
    widget.viajeEnMapaNotifier?.removeListener(_onViajeEnMapaSolicitado);
    widget.shellRefreshTick?.removeListener(_onShellRefresh);
    _busquedaController.dispose();
    _destinoQuery.dispose();
    super.dispose();
  }

  void _onShellRefresh() {
    _cargarEstadoServicios();
  }

  void _onViajeEnMapaSolicitado() {
    final id = widget.viajeEnMapaNotifier?.value;
    if (id == null || !mounted) return;
    _mostrarRutaServicio(id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final n = widget.viajeEnMapaNotifier;
      if (n != null && n.value == id) n.value = null;
    });
  }

  LatLng? _latLngDesdeUbicaciones(List<dynamic> ubicaciones, int? id) {
    if (id == null) return null;
    for (final u in ubicaciones) {
      if (u is! Map) continue;
      final map = Map<String, dynamic>.from(u);
      if (_parseUbicacionId(map['idUbicacion']) == id) {
        final lat = _parseCoord(map['latitud']);
        final lng = _parseCoord(map['longitud']);
        if (lat == null || lng == null) return null;
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  Future<void> _mostrarRutaServicio(int idServicio) async {
    try {
      final res = await http.get(
        Uri.parse('${Config.apiUrl}/servicio/$idServicio'),
      );
      if (res.statusCode != 200 || !mounted) return;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final idSalida = _parseUbicacionId(data['idLugarSalida']);
      final idLlegada = _parseUbicacionId(data['idLugarLlegada']);

      final resU = await http.get(Uri.parse('${Config.apiUrl}/ubicaciones'));
      if (resU.statusCode != 200 || !mounted) return;
      final list = jsonDecode(resU.body) as List<dynamic>;
      final salida = _latLngDesdeUbicaciones(list, idSalida);
      final llegada = _latLngDesdeUbicaciones(list, idLlegada);
      await _aplicarSalidaLlegadaEnMapa(salida, llegada, esViajeEnCurso: true);
    } catch (_) {}
  }

  Future<void> _cargarEstadoServicios() async {
    final prevEnCurso = _idServicioEnCurso;
    int? activo;
    int? enCurso;
    try {
      var res = await http.get(
        Uri.parse(
          '${Config.apiUrl}/servicio/usuario/activo/${SessionManager.idUsuario}',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        activo = (data['idServicio'] as num).toInt();
      } else {
        res = await http.get(
          Uri.parse(
            '${Config.apiUrl}/servicio/usuario/miembro/${SessionManager.idUsuario}',
          ),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          activo = (data['idServicio'] as num).toInt();
        }
      }
    } catch (_) {}

    try {
      final res = await http.get(
        Uri.parse(
          '${Config.apiUrl}/servicio/usuario/encurso/${SessionManager.idUsuario}',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        enCurso = (data['idServicio'] as num).toInt();
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _idServicioActivo = activo;
        _idServicioEnCurso = enCurso;
      });
    }

    if (enCurso != null) {
      await _mostrarRutaServicio(enCurso);
    } else if (prevEnCurso != null && _modoRutaViajeEnCurso) {
      _modoRutaViajeEnCurso = false;
      if (mounted) {
        setState(() {
          _markers = {};
          _polylines = {};
          _puntosRuta = [];
        });
      }
      await _ajustarCamara();
    }
  }

  String? get _mensajeBloqueoCrear {
    if (_idServicioActivo != null) {
      return 'Ya tienes un servicio activo. En la pestaña Viajes abre “Mi grupo” y, si eres creador, cancela o finaliza el viaje para poder crear otro.';
    }
    return null;
  }

  Future<void> _aplicarSalidaLlegadaEnMapa(
    LatLng? salida,
    LatLng? llegada, {
    bool esViajeEnCurso = false,
  }) async {
    final nextMarkers = <Marker>{};
    if (salida != null) {
      nextMarkers.add(
        Marker(
          markerId: const MarkerId('salida'),
          position: salida,
          infoWindow: InfoWindow(
            title: esViajeEnCurso ? 'Salida del viaje' : 'Salida',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
    if (llegada != null) {
      nextMarkers.add(
        Marker(
          markerId: const MarkerId('llegada'),
          position: llegada,
          infoWindow: InfoWindow(
            title: esViajeEnCurso ? 'Destino del viaje' : 'Llegada',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    List<LatLng> ruta = [];
    if (salida != null && llegada != null) {
      ruta = await RouteService.rutaEntre(salida, llegada);
    }

    if (!mounted) return;
    setState(() {
      _modoRutaViajeEnCurso = esViajeEnCurso;
      _markers = nextMarkers;
      _puntosRuta = ruta;
      if (ruta.length >= 2) {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('ruta'),
            points: ruta,
            color: verdePrimario,
            width: 5,
          ),
        };
      } else {
        _polylines = {};
      }
    });

    await _ajustarCamara();
  }

  Future<void> _onCoordenadas(
    LatLng? salida,
    LatLng? llegada, {
    String? aviso,
  }) async {
    if (aviso != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(aviso), duration: const Duration(seconds: 5)),
      );
    }

    await _aplicarSalidaLlegadaEnMapa(salida, llegada, esViajeEnCurso: false);
  }

  Future<void> _ajustarCamara() async {
    if (!_mapController.isCompleted) return;
    final c = await _mapController.future;
    final pts = <LatLng>[..._puntosRuta];
    for (final m in _markers) {
      pts.add(m.position);
    }
    if (pts.isEmpty) {
      await c.animateCamera(CameraUpdate.newLatLngZoom(_centroMedellin, 12));
      return;
    }
    if (pts.length == 1) {
      await c.animateCamera(CameraUpdate.newLatLngZoom(pts.first, 14));
      return;
    }
    double minLat = pts.first.latitude;
    double maxLat = pts.first.latitude;
    double minLng = pts.first.longitude;
    double maxLng = pts.first.longitude;
    for (final p in pts) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    try {
      await c.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
    } catch (_) {
      await c.animateCamera(CameraUpdate.newLatLngZoom(pts.first, 13));
    }
  }

  Future<void> _abrirGrupo(int id) async {
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => GrupoPage(idServicio: id)),
    );
    if (mounted) {
      final t = widget.shellRefreshTick;
      if (t != null) t.value++;
      await _cargarEstadoServicios();
    }
  }

  void _alCrearServicio(int idServicio) {
    if (!mounted) return;
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => GrupoPage(idServicio: idServicio),
      ),
    ).then((_) {
      if (mounted) {
        final t = widget.shellRefreshTick;
        if (t != null) t.value++;
        _cargarEstadoServicios();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _centroMedellin,
            zoom: 12,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (ctrl) {
            if (!_mapController.isCompleted) {
              _mapController.complete(ctrl);
            }
            _ajustarCamara();
          },
        ),
        SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_idServicioEnCurso != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Material(
                    color: verdeSecundario,
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _ajustarCamara(),
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.map, color: Colors.white),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Viaje en curso — Ruta en el mapa',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.zoom_out_map, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Grupo y acciones',
                          onPressed: () => _abrirGrupo(_idServicioEnCurso!),
                          icon: const Icon(Icons.groups, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_idServicioActivo != null && _idServicioEnCurso == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Material(
                    color: verdePrimario,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => _abrirGrupo(_idServicioActivo!),
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.group, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tienes un grupo activo — Ver mi grupo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: '¿A dónde vamos?',
                      prefixIcon:
                          const Icon(Icons.search, color: verdePrimario),
                      suffixIcon: _busquedaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _busquedaController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.42,
          minChildSize: 0.18,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: verdePrimario.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_road, color: verdePrimario),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Crear servicio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: verdePrimario,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige salida y destino: la ruta en el mapa usa las coordenadas del servidor.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  CrearServicioForm(
                    destinoQueryNotifier: _destinoQuery,
                    bloqueoCrearMensaje: _mensajeBloqueoCrear,
                    onCoordenadasSeleccion: _onCoordenadas,
                    onServicioCreado: _alCrearServicio,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
