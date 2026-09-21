import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrivacidadScreen extends StatefulWidget {
  const PrivacidadScreen({super.key});

  @override
  State<PrivacidadScreen> createState() => _PrivacidadScreenState();
}

class _PrivacidadScreenState extends State<PrivacidadScreen> {
  bool _aceptaRecoleccion = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios/${user.uid}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aceptaRecoleccion = data['acepta_recoleccion'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar preferencias: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarPreferencias() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() => _isSaving = true);

      final response = await http.put(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios/${user.uid}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'acepta_recoleccion': _aceptaRecoleccion,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Preferencias guardadas'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al guardar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad y Seguridad'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recolección de datos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu privacidad es importante para nosotros. Puedes elegir si permites que tus datos de navegación y preferencias sean recolectados para recibir sugerencias de productos personalizados.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Checkbox(
                    value: _aceptaRecoleccion,
                    onChanged: (value) {
                      setState(() {
                        _aceptaRecoleccion = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Acepto que mis datos de navegación y preferencias sean recolectados para recibir sugerencias de productos personalizados.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            if (!_isLoading)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardarPreferencias,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : const Text(
                          'Guardar preferencias',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}