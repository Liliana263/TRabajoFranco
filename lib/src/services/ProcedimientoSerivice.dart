import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ProcedimientoModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProcedimientoService {
  static Future<List<Procedimiento>> listarProcedimientos() async {
    try {
      // 1) Asegura que dotenv esté cargado
      if (dotenv.isInitialized == false) {
        // si ya lo cargas en main(), no pasa nada por llamar again
        await dotenv.load(fileName: ".env");
      }

      final baseUrl = dotenv.env['API_BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        print('❌ ERROR: API_BASE_URL no está definido en .env');
        return [];
      }

      final url = Uri.parse('$baseUrl/apiprocedimientos/listarprocedimiento');
      print('➡️ GET $url');

      // 2) timeout para evitar quedarse colgado
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      print('⬅️ status: ${response.statusCode}');
      // usa bodyBytes para evitar problemas de encoding
      final bodyText = utf8.decode(response.bodyBytes);
      print('⬇️ body:\n$bodyText');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(bodyText);

        // 3) Soporta dos formatos: lista directa o {data: [...]}
        final list = (decoded is List)
            ? decoded
            : (decoded is Map && decoded['data'] is List)
                ? decoded['data']
                : null;

        if (list == null) {
          print('❌ La respuesta no es una lista de procedimientos');
          return [];
        }

        return (list as List)
            .map((item) => Procedimiento.fromJson(item))
            .toList();
      } else {
        // 4) Log completo cuando no es 200
        throw Exception('Error HTTP ${response.statusCode}: $bodyText');
      }
    } catch (e, st) {
      print('💥 listarProcedimientos() falló: $e');
      print(st);
      return [];
    }
  }
}
