package com.proyect.gopoli.security;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

import com.proyect.gopoli.model.Servicio;
import com.proyect.gopoli.model.Usuario;
import com.proyect.gopoli.repository.UsuarioRepository;

@Component
public class JwtAuthSupport {

    @Autowired
    private JwtService jwtService;

    @Autowired
    private UsuarioRepository usuarioRepo;

    public Optional<Usuario> usuarioFromAuth(String authorization) {
        Integer id = jwtService.parseUserId(authorization);
        if (id == null) {
            return Optional.empty();
        }
        return usuarioRepo.findById(id);
    }

    public ResponseEntity<?> unauthorized() {
        return ResponseEntity.status(401).body("Token inválido o ausente");
    }

    public ResponseEntity<?> forbidden() {
        return ResponseEntity.status(403).body("No autorizado para esta acción");
    }

    public boolean esCreador(Servicio servicio, Usuario usuario) {
        return servicio.getIdCreador() != null
                && servicio.getIdCreador().equals(usuario.getIdUsuario());
    }

    public boolean mismoUsuario(Usuario usuario, Integer idUsuario) {
        return idUsuario != null && idUsuario.equals(usuario.getIdUsuario());
    }
}
