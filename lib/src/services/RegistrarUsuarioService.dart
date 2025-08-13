import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/Usuariomodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<bool> registrarUsuario(Usuario usuario) async {
  final baseUrl = dotenv.env['API_BASE_URL'];

  if (baseUrl == null) {
    print('ERROR: API_BASE_URL no está definido en el archivo .env');
    return false;
  }

  // Validaciones mínimas (evita 400)
  if ((usuario.contrasena ?? '').length < 6) {
    print('ERROR: La contraseña debe tener al menos 6 caracteres');
    return false;
  }

  final url = Uri.parse('$baseUrl/apiusuarios/crearusuarios');

  // Tomamos el JSON del modelo y le inyectamos el booleano requerido
  final Map<String, dynamic> body = {
    ...usuario.toJson(),
    'terminos_condiciones': true, // ← CLAVE: booleano real
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(body),
    );

    print(' Cuerpo enviado (JSON): ${jsonEncode(body)}');
    print(' Código de respuesta: ${response.statusCode}');
    print(' Respuesta body:\n${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' Usuario registrado exitosamente.');
      return true;
    } else {
      // Intenta mostrar mensajes amigables si viene el arreglo "errores"
      try {
        final data = jsonDecode(response.body);
        final errores = (data['errores'] as List?)
                ?.map((e) => e['msg'])
                .join('\n') ??
            'Error ${response.statusCode}';
        print(' Detalles legibles: $errores');
      } catch (_) {
        // Si no es JSON, imprime bruto
      }
      print(' Error al registrar: ${response.statusCode}');
      print(' Detalles: ${response.body}');
      return false;
    }
  } catch (e) {
    print(' Excepción al registrar: $e');
    return false;
  }
}
