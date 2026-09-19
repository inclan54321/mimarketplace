import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _mensajes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('INITSTATE EJECUTADO');
    _cargarMensajes();
  }

  Future<void> _cargarMensajes() async {
    try {
      print('Cargando mensajes...');
      final response = await http.get(
        Uri.parse('http://192.168.100.248:3000/api/mensajes/1'),
      );
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('Datos recibidos: $data');
        setState(() {
          _mensajes.clear();
          for (var item in data) {
            _mensajes.add({
              'texto': item['texto'] ?? '',
              'usuario': item['usuario_id'] ?? 'Desconocido',
              'hora': item['fecha'] != null
                  ? DateTime.parse(item['fecha']).toString().substring(11, 16)
                  : '',
            });
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error al cargar mensajes: $e');
      setState(() => _isLoading = false);
    }
  }

  void _enviarMensaje() async {
    if (_controller.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.248:3000/api/mensajes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'conversacion_id': '1',
          'usuario_id': user?.uid ?? '',
          'texto': _controller.text,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _mensajes.add({
            'texto': _controller.text,
            'usuario': user?.displayName ?? 'Yo',
            'hora': DateTime.now().toString().substring(11, 16),
          });
          _controller.clear();
        });
      }
    } catch (e) {
      print('Error al enviar mensaje: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _mensajes.length,
                    itemBuilder: (context, index) {
                      final mensaje = _mensajes[_mensajes.length - 1 - index];
                      final esMio = mensaje['usuario'] == (user?.displayName ?? 'Yo') ||
                          mensaje['usuario'] == user?.uid;
                      return Align(
                        alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: esMio ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mensaje['texto']!,
                                style: TextStyle(
                                  color: esMio ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                mensaje['hora']!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: esMio ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                            ),
                          ),
                          onSubmitted: (_) => _enviarMensaje(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: _enviarMensaje,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}