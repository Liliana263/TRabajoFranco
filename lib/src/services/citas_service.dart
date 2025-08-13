import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitasService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Ajusta la clave si usas otra
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /citas/disponibilidad?servicioId=...&fecha=YYYY-MM-DD
  static Future<List<String>> obtenerDisponibilidad({
    required int servicioId,
    required DateTime fecha,
  }) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) throw Exception('API_BASE_URL no configurado en .env');

    final fechaStr = fecha.toIso8601String().substring(0, 10); // YYYY-MM-DD
    final uri = Uri.parse(
      '$baseUrl/citas/disponibilidad?servicioId=$servicioId&fecha=$fechaStr',
    );

    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data as List).map((e) => e.toString()).toList(); // ["08:00",...]
    } else {
      throw Exception('Error disponibilidad (${res.statusCode}): ${res.body}');
    }
  }

  /// POST /citas
  /// Body:
  /// { "servicioId":1, "fecha":"2025-08-13", "hora":"09:00", "duracionMin": 30 }
  static Future<void> agendarCita({
    required int servicioId,
    required DateTime fecha,
    required String hora,
    required int duracionMin,
  }) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) throw Exception('API_BASE_URL no configurado en .env');

    final uri = Uri.parse('$baseUrl/citas');
    final body = jsonEncode({
      'servicioId': servicioId,
      'fecha': fecha.toIso8601String().substring(0, 10),
      'hora': hora,
      'duracionMin': duracionMin,
    });

    final res = await http.post(uri, headers: await _headers(), body: body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('No se pudo agendar (${res.statusCode}): ${res.body}');
    }
  }
}
