import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = 'http://192.168.100.248:3000/api';

  Future<List<dynamic>> getConversaciones(String usuarioId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversaciones/$usuarioId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<List<dynamic>> getMensajes(String conversacionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mensajes/$conversacionId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<void> enviarMensaje(String conversacionId, String texto, String usuarioId) async {
    await http.post(
      Uri.parse('$baseUrl/mensajes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversacion_id': conversacionId,
        'usuario_id': usuarioId,
        'texto': texto,
      }),
    );
  }

  Future<Map<String, dynamic>> verificarCalificacionPendiente(String conversacionId, String usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.248:3000/api/conversaciones/$conversacionId/calificacion-pendiente?usuario_id=$usuarioId'),
      );

      // 🔥 PRINT DE LA RESPUESTA CRUDA
      print('>>> 🔥 ChatService - RESPUESTA CRUDA: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('>>> 🔥 ChatService - STATUS CODE NO ES 200: ${response.statusCode}');
        return {'pendiente': false};
      }
    } catch (e) {
      print('Error en verificarCalificacionPendiente: $e');
      return {'pendiente': false};
    }
  }
}