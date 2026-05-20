import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../core/api_exception.dart';
import '../models/carrera.dart';

class CatalogoService {
  const CatalogoService();

  Future<List<Carrera>> obtenerCarreras() async {
    try {
      final response = await http
          .get(Uri.parse('${Config.apiUrl}/carreras'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response.statusCode, response.body);
      }

      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Carrera.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'No se pudo conectar con el servidor (${Config.apiUrl})',
      );
    }
  }
}
