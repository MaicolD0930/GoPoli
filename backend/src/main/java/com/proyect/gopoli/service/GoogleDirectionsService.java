package com.proyect.gopoli.service;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Service
public class GoogleDirectionsService {

    private static final Pattern OVERVIEW_POINTS_PATTERN = Pattern.compile(
            "\"overview_polyline\"\\s*:\\s*\\{\\s*\"points\"\\s*:\\s*\"([^\"]+)\"");

    private final RestClient restClient = RestClient.create();

    @Value("${gopoli.google.maps.api-key:}")
    private String apiKey;

    /**
     * Ruta por carretera entre dos puntos. Vacío si no hay clave o falla la API.
     */
    public List<Map<String, Double>> rutaEntre(
            double origenLat,
            double origenLng,
            double destinoLat,
            double destinoLng,
            String mode) {
        if (apiKey == null || apiKey.isBlank()) {
            return List.of();
        }
        String travelMode = (mode == null || mode.isBlank()) ? "driving" : mode;
        try {
            String origin = origenLat + "," + origenLng;
            String destination = destinoLat + "," + destinoLng;
            URI uri = URI.create(
                    "https://maps.googleapis.com/maps/api/directions/json?origin="
                            + URLEncoder.encode(origin, StandardCharsets.UTF_8)
                            + "&destination="
                            + URLEncoder.encode(destination, StandardCharsets.UTF_8)
                            + "&mode="
                            + URLEncoder.encode(travelMode, StandardCharsets.UTF_8)
                            + "&key="
                            + URLEncoder.encode(apiKey, StandardCharsets.UTF_8));

            String body = restClient.get().uri(uri).retrieve().body(String.class);
            if (body == null || body.isBlank()) {
                return List.of();
            }

            Matcher matcher = OVERVIEW_POINTS_PATTERN.matcher(body);
            if (!matcher.find()) {
                return List.of();
            }

            return decodePolyline(matcher.group(1));
        } catch (Exception e) {
            return List.of();
        }
    }

    static List<Map<String, Double>> decodePolyline(String encoded) {
        List<Map<String, Double>> path = new ArrayList<>();
        int index = 0;
        int lat = 0;
        int lng = 0;

        while (index < encoded.length()) {
            int shift = 0;
            int result = 0;
            int b;
            do {
                b = encoded.charAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
            lat += dlat;

            shift = 0;
            result = 0;
            do {
                b = encoded.charAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
            lng += dlng;

            Map<String, Double> point = new LinkedHashMap<>();
            point.put("lat", lat / 1e5);
            point.put("lng", lng / 1e5);
            path.add(point);
        }
        return path;
    }
}
