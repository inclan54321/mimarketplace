import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosUsuario();
    });
  }

  Future<void> _cargarDatosUsuario() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = l10n.usuarioNoAutenticado;
          _isLoading = false;
        });
        return;
      }

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios/${user.uid}'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nombreController.text = data['nombre'] ?? user.displayName ?? '';
          _telefonoController.text = data['telefono'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = l10n.errorAlCargarDatos;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = l10n.errorGenerico('$e');
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    final l10n = AppLocalizations.of(context)!;
    final nombre = _nombreController.text.trim();
    final telefono = _telefonoController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.nombreNoPuedeEstarVacio),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception(l10n.usuarioNoAutenticado);

      // 🔥 ACTUALIZAR EN FIREBASE AUTH (displayName)
      await user.updateDisplayName(nombre);

      // 🔥 ACTUALIZAR EN EL BACKEND
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      print('>>> 👤 Editar perfil. Token: ${idToken != null ? "SÍ" : "NO"}');
      final response = await http.put(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios/${user.uid}'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'nombre': nombre,
          'telefono': telefono,
        }),
      );

      if (response.statusCode == 200) {
        // 🔥 ACTUALIZAR CACHÉ LOCAL
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nombre_usuario', nombre);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.perfilActualizadoCorrectamente),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Devolver true para refrescar
        }
      } else {
        throw Exception(l10n.errorAlGuardarEnServidor);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGenerico('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editarPerfil),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _guardarCambios,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.guardar,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDatosUsuario,
                        child: Text(l10n.reintentar),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 🔥 AVATAR CON FOTO DE PERFIL
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                _nombreController.text.isNotEmpty
                                    ? _nombreController.text[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🔥 CAMPO NOMBRE
                      TextField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: l10n.nombreCompleto,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔥 CAMPO TELÉFONO
                      TextField(
                        controller: _telefonoController,
                        decoration: InputDecoration(
                          labelText: l10n.telefono,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // 🔥 CAMPO EMAIL (SOLO LECTURA)
                      TextField(
                        controller: TextEditingController(
                          text: FirebaseAuth.instance.currentUser?.email ?? '',
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.correoElectronico,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.grey,
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 30),

                      // 🔥 BOTÓN GUARDAR (FULL WIDTH)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _guardarCambios,
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
                              : Text(
                                  l10n.guardarCambios,
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