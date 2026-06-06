import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TripTypeBadge extends StatelessWidget {
  const TripTypeBadge({
    super.key,
    required this.tripTypeLabel,
    this.idTipoServicio,
  });

  final String? tripTypeLabel;
  final dynamic idTipoServicio;

  String get _label {
    if (tripTypeLabel != null && tripTypeLabel!.isNotEmpty) {
      return tripTypeLabel!;
    }
    final id = idTipoServicio is num
        ? (idTipoServicio as num).toInt()
        : int.tryParse(idTipoServicio?.toString() ?? '');
    if (id == 3) return 'Grupo conductor';
    return 'Grupo de viaje';
  }

  Color get _color {
    final id = idTipoServicio is num
        ? (idTipoServicio as num).toInt()
        : int.tryParse(idTipoServicio?.toString() ?? '');
    if (id == 3 || _label.toLowerCase().contains('conductor')) {
      return AppColors.conductor;
    }
    return AppColors.verdePrimario;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
