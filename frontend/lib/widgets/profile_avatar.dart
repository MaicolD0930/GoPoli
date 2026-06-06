import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Avatar circular con foto base64 o icono por defecto.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.fotoBase64,
    this.radius = 50,
    this.onTap,
  });

  final String? fotoBase64;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget child;
    final bytes = _decode(fotoBase64);
    if (bytes != null) {
      child = ClipOval(
        child: Image.memory(
          Uint8List.fromList(bytes),
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        ),
      );
    } else {
      child = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.verdePrimario.withValues(alpha: 0.12),
        child: Icon(
          Icons.person,
          size: radius * 1.4,
          color: AppColors.verdeSecundario,
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }
    return child;
  }

  static List<int>? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      var data = raw;
      if (data.contains(',')) {
        data = data.split(',').last;
      }
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }
}

/// Badge de calificación (HU-04).
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.nota});

  final double? nota;

  @override
  Widget build(BuildContext context) {
    final valor = nota ?? 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amarillo.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amarillo),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.amarillo, size: 18),
          const SizedBox(width: 4),
          Text(
            valor.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.verdePrimario,
            ),
          ),
        ],
      ),
    );
  }
}
