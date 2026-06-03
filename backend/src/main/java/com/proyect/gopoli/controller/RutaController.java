package com.proyect.gopoli.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.proyect.gopoli.service.GoogleDirectionsService;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/ruta")
public class RutaController {

    @Autowired
    private GoogleDirectionsService directionsService;

    /**
     * Puntos de la ruta por carretera (Google Directions). mode: driving | transit
     */
    @GetMapping("/direcciones")
    public ResponseEntity<?> direcciones(
            @RequestParam double origenLat,
            @RequestParam double origenLng,
            @RequestParam double destinoLat,
            @RequestParam double destinoLng,
            @RequestParam(defaultValue = "driving") String mode) {
        List<Map<String, Double>> puntos = directionsService.rutaEntre(
                origenLat, origenLng, destinoLat, destinoLng, mode);

        if (puntos.size() < 3) {
            Map<String, Object> fallback = new LinkedHashMap<>();
            fallback.put("puntos", List.of(
                    Map.of("lat", origenLat, "lng", origenLng),
                    Map.of("lat", destinoLat, "lng", destinoLng)));
            fallback.put("porCarretera", false);
            fallback.put("mensaje", "No se pudo calcular ruta por carretera. Revisa GOOGLE_MAPS_API_KEY y Directions API.");
            return ResponseEntity.ok(fallback);
        }

        Map<String, Object> ok = new LinkedHashMap<>();
        ok.put("puntos", puntos);
        ok.put("porCarretera", true);
        return ResponseEntity.ok(ok);
    }
}
