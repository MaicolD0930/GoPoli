package com.proyect.gopoli.controller;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.proyect.gopoli.dto.UsuarioDto;
import com.proyect.gopoli.model.GoPoliConstants;
import com.proyect.gopoli.model.Servicio;
import com.proyect.gopoli.model.ServicioUsuario;
import com.proyect.gopoli.model.ServicioUsuarioId;
import com.proyect.gopoli.model.Ubicacion;
import com.proyect.gopoli.model.Usuario;
import com.proyect.gopoli.model.UsuarioEstado;
import com.proyect.gopoli.model.Vehiculo;
import com.proyect.gopoli.repository.ServicioRepository;
import com.proyect.gopoli.repository.ServicioUsuarioRepository;
import com.proyect.gopoli.repository.UbicacionRepository;
import com.proyect.gopoli.repository.UsuarioRepository;
import com.proyect.gopoli.repository.VehiculoRepository;
import com.proyect.gopoli.security.JwtAuthSupport;
import com.proyect.gopoli.util.VehicleValidator;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/usuario")
public class UsuarioController {

    @Autowired
    private UsuarioRepository repo;

    @Autowired
    private VehiculoRepository vehiculoRepo;

    @Autowired
    private JwtAuthSupport authSupport;

    @Autowired
    private ServicioUsuarioRepository servicioUsuarioRepo;

    @Autowired
    private ServicioRepository servicioRepo;

    @Autowired
    private UbicacionRepository ubicacionRepo;

    private Optional<Usuario> usuarioAutenticado(String authorization) {
        return authSupport.usuarioFromAuth(authorization);
    }

    private ResponseEntity<?> noAutorizado() {
        return authSupport.unauthorized();
    }

    private UsuarioDto dtoConVehiculo(Usuario usuario) {
        Vehiculo v = vehiculoRepo.findByIdUsuario(usuario.getIdUsuario()).orElse(null);
        return UsuarioDto.from(usuario, v);
    }

    @GetMapping("/me")
    public ResponseEntity<?> obtenerPerfil(@RequestHeader(value = "Authorization", required = false) String auth) {
        Optional<Usuario> usuario = usuarioAutenticado(auth);
        if (usuario.isEmpty()) {
            return noAutorizado();
        }
        if (usuario.get().getIdEstado() != null
                && usuario.get().getIdEstado() == UsuarioEstado.INHABILITADO) {
            return ResponseEntity.status(403).body("Cuenta inhabilitada");
        }
        return ResponseEntity.ok(dtoConVehiculo(usuario.get()));
    }

    @PutMapping("/me")
    public ResponseEntity<?> actualizarPerfil(
            @RequestHeader(value = "Authorization", required = false) String auth,
            @RequestBody Map<String, String> body) {
        Optional<Usuario> opt = usuarioAutenticado(auth);
        if (opt.isEmpty()) {
            return noAutorizado();
        }
        Usuario usuario = opt.get();
        if (usuario.getIdEstado() != null && usuario.getIdEstado() == UsuarioEstado.INHABILITADO) {
            return ResponseEntity.status(403).body("Cuenta inhabilitada");
        }

        String nombre = body.get("nombre");
        String tel = body.get("tel");
        String correo = body.get("correo");

        if (nombre != null && !nombre.isBlank()) {
            usuario.setNombre(nombre.trim());
        }
        if (tel != null) {
            usuario.setTel(tel.trim());
        }
        if (correo != null && !correo.isBlank()) {
            String nuevoCorreo = correo.trim();
            Optional<Usuario> otro = repo.findByCorreo(nuevoCorreo);
            if (otro.isPresent() && !otro.get().getIdUsuario().equals(usuario.getIdUsuario())) {
                return ResponseEntity.status(409).body("El correo ya está en uso");
            }
            usuario.setCorreo(nuevoCorreo);
        }

        return ResponseEntity.ok(dtoConVehiculo(repo.save(usuario)));
    }

    @PutMapping("/me/foto")
    public ResponseEntity<?> actualizarFoto(
            @RequestHeader(value = "Authorization", required = false) String auth,
            @RequestBody Map<String, String> body) {
        Optional<Usuario> opt = usuarioAutenticado(auth);
        if (opt.isEmpty()) {
            return noAutorizado();
        }
        String foto = body.get("fotoBase64");
        if (foto == null || foto.isBlank()) {
            return ResponseEntity.status(400).body("fotoBase64 es obligatorio");
        }
        if (foto.length() > 2_000_000) {
            return ResponseEntity.status(400).body("La imagen es demasiado grande");
        }
        Usuario usuario = opt.get();
        usuario.setFotoPerfil(foto);
        return ResponseEntity.ok(dtoConVehiculo(repo.save(usuario)));
    }

    @PostMapping("/me/register-driver")
    public ResponseEntity<?> registerAsDriver(
            @RequestHeader(value = "Authorization", required = false) String auth,
            @RequestBody Map<String, String> body) {
        Optional<Usuario> opt = usuarioAutenticado(auth);
        if (opt.isEmpty()) {
            return noAutorizado();
        }
        Usuario usuario = opt.get();

        if (GoPoliConstants.esConductor(usuario.getIdTipoUsuario())) {
            return ResponseEntity.status(400).body("Ya eres conductor");
        }

        String marca = body.get("marca");
        String modelo = body.get("modelo");
        String color = body.get("color");
        String placa = body.get("placa");

        Map<String, String> errores = VehicleValidator.validate(marca, modelo, color, placa);
        if (!errores.isEmpty()) {
            return ResponseEntity.status(400).body(errores);
        }

        String placaNorm = VehicleValidator.normalizePlaca(placa);
        if (vehiculoRepo.existsByMatricula(placaNorm)) {
            return ResponseEntity.status(409).body(Map.of("placa", "Esta placa ya está registrada"));
        }

        Vehiculo vehiculo = new Vehiculo();
        vehiculo.setIdUsuario(usuario.getIdUsuario());
        vehiculo.setMarca(marca.trim());
        vehiculo.setModelo(modelo.trim());
        vehiculo.setColor(color.trim());
        vehiculo.setMatricula(placaNorm);
        vehiculo.setCapacidad(4);
        vehiculoRepo.save(vehiculo);

        usuario.setIdTipoUsuario(GoPoliConstants.TIPO_USUARIO_CONDUCTOR);
        repo.save(usuario);

        return ResponseEntity.ok(dtoConVehiculo(usuario));
    }

    @PostMapping("/me/unregister-driver")
    public ResponseEntity<?> unregisterAsDriver(
            @RequestHeader(value = "Authorization", required = false) String auth) {
        Optional<Usuario> opt = usuarioAutenticado(auth);
        if (opt.isEmpty()) {
            return noAutorizado();
        }
        Usuario usuario = opt.get();

        if (!GoPoliConstants.esConductor(usuario.getIdTipoUsuario())) {
            return ResponseEntity.status(400).body("No eres conductor");
        }

        List<Servicio> activosConductor = servicioRepo.findByIdCreadorAndIdEstadoServicio(
                usuario.getIdUsuario(), GoPoliConstants.ESTADO_SERVICIO_ACTIVO);
        for (Servicio s : activosConductor) {
            if (GoPoliConstants.esViajeConductor(s.getIdTipoServicio())) {
                return ResponseEntity.status(400).body(
                        "Tienes un viaje conductor activo. Cancélalo o finalízalo antes de dejar de ser conductor.");
            }
        }

        List<Servicio> enCurso = servicioRepo.findByIdCreadorAndIdEstadoServicio(
                usuario.getIdUsuario(), GoPoliConstants.ESTADO_SERVICIO_EN_CURSO);
        for (Servicio s : enCurso) {
            if (GoPoliConstants.esViajeConductor(s.getIdTipoServicio())) {
                return ResponseEntity.status(400).body(
                        "Tienes un viaje conductor en curso. Finalízalo antes de dejar de ser conductor.");
            }
        }

        vehiculoRepo.findByIdUsuario(usuario.getIdUsuario()).ifPresent(vehiculoRepo::delete);
        usuario.setIdTipoUsuario(GoPoliConstants.TIPO_USUARIO_PASAJERO);
        repo.save(usuario);

        return ResponseEntity.ok(dtoConVehiculo(usuario));
    }

    @GetMapping("/me/historial-viajes")
    public ResponseEntity<?> historialViajes(
            @RequestHeader(value = "Authorization", required = false) String auth) {
        Optional<Usuario> opt = usuarioAutenticado(auth);
        if (opt.isEmpty()) {
            return noAutorizado();
        }
        Integer idUsuario = opt.get().getIdUsuario();

        List<ServicioUsuario> membresias = servicioUsuarioRepo.findByIdUsuario(idUsuario);
        List<Map<String, Object>> historial = new ArrayList<>();

        for (ServicioUsuario su : membresias) {
            Optional<Servicio> servicioOpt = servicioRepo.findById(su.getIdServicio());
            if (servicioOpt.isEmpty()) continue;
            Servicio s = servicioOpt.get();
            if (s.getIdEstadoServicio() == null
                    || s.getIdEstadoServicio() != GoPoliConstants.ESTADO_SERVICIO_FINALIZADO) {
                continue;
            }

            Map<String, Object> item = new LinkedHashMap<>();
            item.put("idServicio", s.getIdServicio());
            item.put("fecha", s.getFecha());
            item.put("horaSalida", s.getHoraSalida());
            item.put("descripcion", s.getDescripcion());
            item.put("idTipoServicio", s.getIdTipoServicio());
            item.put("tripType", tripTypeKey(s.getIdTipoServicio()));
            item.put("tripTypeLabel", tripTypeLabel(s.getIdTipoServicio()));
            item.put("idLugarSalida", s.getIdLugarSalida());
            item.put("idLugarLlegada", s.getIdLugarLlegada());
            item.put("nombreSalida", nombreUbicacion(s.getIdLugarSalida()));
            item.put("nombreLlegada", nombreUbicacion(s.getIdLugarLlegada()));
            item.put("miRolParticipacion", su.getRolParticipacion());
            item.put("miRolParticipacionLabel", rolParticipacionLabel(su.getRolParticipacion()));

            List<Map<String, Object>> participantes = new ArrayList<>();
            for (ServicioUsuario m : servicioUsuarioRepo.findByIdServicio(s.getIdServicio())) {
                Map<String, Object> p = new LinkedHashMap<>();
                p.put("idUsuario", m.getIdUsuario());
                p.put("rolGrupo", m.getRol());
                p.put("rolParticipacion", m.getRolParticipacion());
                p.put("rolParticipacionLabel", rolParticipacionLabel(m.getRolParticipacion()));
                repo.findById(m.getIdUsuario()).ifPresent(u -> p.put("nombreUsuario", u.getNombre()));
                participantes.add(p);
            }
            item.put("participantes", participantes);
            historial.add(item);
        }

        historial.sort(Comparator
                .comparing((Map<String, Object> m) -> (java.time.LocalDate) m.get("fecha"), Comparator.nullsLast(Comparator.reverseOrder()))
                .thenComparing(m -> (java.time.LocalTime) m.get("horaSalida"), Comparator.nullsLast(Comparator.reverseOrder())));

        if (historial.size() > 10) {
            historial = historial.subList(0, 10);
        }

        return ResponseEntity.ok(historial);
    }

    private String nombreUbicacion(Integer id) {
        if (id == null) return null;
        return ubicacionRepo.findById(id).map(Ubicacion::getNombreUbicacion).orElse(null);
    }

    private static String tripTypeKey(Integer idTipoServicio) {
        if (GoPoliConstants.esViajeConductor(idTipoServicio)) {
            return "driver_group";
        }
        return "passenger_group";
    }

    private static String tripTypeLabel(Integer idTipoServicio) {
        if (GoPoliConstants.esViajeConductor(idTipoServicio)) {
            return "Grupo conductor";
        }
        return "Grupo de viaje";
    }

    private static String rolParticipacionLabel(String rol) {
        if (GoPoliConstants.ROL_PARTICIPACION_DRIVER.equals(rol)) {
            return "Conductor";
        }
        return "Pasajero";
    }

    @PostMapping("/{idUsuario}/calificar")
    public ResponseEntity<?> calificarUsuario(
            @PathVariable Integer idUsuario,
            @RequestBody Map<String, Object> body,
            @RequestHeader(value = "Authorization", required = false) String auth) {
        Optional<Usuario> calificadorOpt = usuarioAutenticado(auth);
        if (calificadorOpt.isEmpty()) {
            return noAutorizado();
        }
        Usuario calificador = calificadorOpt.get();
        if (calificador.getIdUsuario().equals(idUsuario)) {
            return ResponseEntity.status(400).body("No puedes calificarte a ti mismo");
        }

        Object rawServicio = body.get("idServicio");
        if (rawServicio == null) {
            return ResponseEntity.status(400).body("El idServicio es obligatorio");
        }
        Integer idServicio;
        try {
            idServicio = rawServicio instanceof Number
                    ? ((Number) rawServicio).intValue()
                    : Integer.parseInt(rawServicio.toString());
        } catch (NumberFormatException e) {
            return ResponseEntity.status(400).body("idServicio inválido");
        }

        Optional<Servicio> servicioOpt = servicioRepo.findById(idServicio);
        if (servicioOpt.isEmpty()) {
            return ResponseEntity.status(404).body("Viaje no encontrado");
        }
        Servicio servicio = servicioOpt.get();
        if (servicio.getIdEstadoServicio() == null
                || servicio.getIdEstadoServicio() != GoPoliConstants.ESTADO_SERVICIO_FINALIZADO) {
            return ResponseEntity.status(400).body("Solo puedes calificar tras un viaje finalizado");
        }

        ServicioUsuarioId idCalificador = new ServicioUsuarioId(idServicio, calificador.getIdUsuario());
        ServicioUsuarioId idObjetivo = new ServicioUsuarioId(idServicio, idUsuario);
        if (servicioUsuarioRepo.findById(idCalificador).isEmpty()
                || servicioUsuarioRepo.findById(idObjetivo).isEmpty()) {
            return ResponseEntity.status(403).body("No compartiste este viaje con ese usuario");
        }

        Object raw = body.get("puntuacion");
        if (raw == null) {
            return ResponseEntity.status(400).body("La puntuación es obligatoria");
        }
        double puntuacion;
        try {
            puntuacion = raw instanceof Number ? ((Number) raw).doubleValue() : Double.parseDouble(raw.toString());
        } catch (NumberFormatException e) {
            return ResponseEntity.status(400).body("Puntuación inválida");
        }
        if (puntuacion < 1 || puntuacion > 5) {
            return ResponseEntity.status(400).body("La puntuación debe estar entre 1 y 5");
        }

        Optional<Usuario> objetivoOpt = repo.findById(idUsuario);
        if (objetivoOpt.isEmpty()) {
            return ResponseEntity.status(404).body("Usuario no encontrado");
        }
        Usuario objetivo = objetivoOpt.get();

        double actual = objetivo.getNota() != null ? objetivo.getNota() : 0.0;
        double nuevaNota = actual <= 0 ? puntuacion : (actual + puntuacion) / 2.0;
        objetivo.setNota(Math.round(nuevaNota * 10.0) / 10.0);
        repo.save(objetivo);

        return ResponseEntity.ok(Map.of(
                "idUsuario", objetivo.getIdUsuario(),
                "nota", objetivo.getNota()));
    }

    @PostMapping("/me/inhabilitar")
    public ResponseEntity<?> inhabilitarCuenta(
            @RequestHeader(value = "Authorization", required = false) String auth) {
        Optional<Usuario> opt = usuarioAutenticado(auth);
        if (opt.isEmpty()) {
            return noAutorizado();
        }
        Usuario usuario = opt.get();
        usuario.setIdEstado(UsuarioEstado.INHABILITADO);
        repo.save(usuario);
        return ResponseEntity.ok("Cuenta inhabilitada");
    }

    @DeleteMapping("/me")
    public ResponseEntity<?> eliminarCuenta(
            @RequestHeader(value = "Authorization", required = false) String auth) {
        Optional<Usuario> opt = usuarioAutenticado(auth);
        if (opt.isEmpty()) {
            return noAutorizado();
        }
        vehiculoRepo.findByIdUsuario(opt.get().getIdUsuario()).ifPresent(vehiculoRepo::delete);
        repo.delete(opt.get());
        return ResponseEntity.ok("Cuenta eliminada permanentemente");
    }
}
