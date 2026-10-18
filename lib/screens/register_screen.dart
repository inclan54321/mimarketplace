import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  
  // 🔥 NUEVA VARIABLE PARA EL CHECKBOX
  bool _aceptaRecoleccionDatos = false;

  // 🔥 NUEVA: FOTO DE PERFIL OBLIGATORIA
  File? _fotoPerfil;
  bool _subiendoFoto = false;

  Future<void> _register() async {
    // 🔥 VALIDAR QUE EL CHECKBOX ESTÉ MARCADO
    if (!_aceptaRecoleccionDatos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar la recolección de datos para continuar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 🔥 VALIDAR QUE LA FOTO DE PERFIL ESTÉ SELECCIONADA
    if (_fotoPerfil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una foto de perfil para continuar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await credential.user?.updateDisplayName(_nameController.text.trim());

      // 🔥 ENVIAR EL CAMPO DE CONSENTIMIENTO AL BACKEND
      // 🔥 forceRefresh: true para que Firebase genere un token fresco
      // 🔥 (el usuario acaba de crear la cuenta, el token puede no estar en caché todavía)
      final idToken = await credential.user?.getIdToken(true);
      print('>>> 📝 Crear usuario. Token: ${idToken != null ? "SÍ" : "NO"}');
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': credential.user?.uid,
          'email': _emailController.text.trim(),
          'nombre': _nameController.text.trim(),
          'telefono': _phoneController.text.trim(),
          'acepta_recoleccion': _aceptaRecoleccionDatos, // 🔥 NUEVO CAMPO
        }),
      );
      print('>>> 📝 Respuesta crear usuario: ${response.statusCode}');
      if (response.statusCode != 201) {
        print('>>> ❌ Error body: ${response.body}');
      }

      // 🔥 SUBIR LA FOTO DE PERFIL
      await _subirFotoPerfil(credential.user!.uid);

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 🔥 SELECCIONAR FOTO DE PERFIL (galería o cámara)
  Future<void> _seleccionarFoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (imagen == null) return;
    setState(() {
      _fotoPerfil = File(imagen.path);
    });
  }

  // 🔥 BOTTOM SHEET PARA ELEGIR CÁMARA O GALERÍA
  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(ctx);
                _seleccionarFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(ctx);
                _seleccionarFoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 SUBIR LA FOTO AL BACKEND
  Future<void> _subirFotoPerfil(String uid) async {
    if (_fotoPerfil == null) return;

    setState(() => _subiendoFoto = true);
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://mimarketplace-production.up.railway.app/api/registro/foto'),
      );

      // 🔥 Mandar el token de Firebase para autenticar la subida
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        request.headers['Authorization'] = 'Bearer $idToken';
      }

      request.fields['uid'] = uid;
      request.files.add(
        await http.MultipartFile.fromPath('foto', _fotoPerfil!.path),
      );
      final response = await request.send();
      print('>>> Subida foto status: ${response.statusCode}');
    } catch (e) {
      print('>>> Error subiendo foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La cuenta se creó pero la foto no se pudo subir. Podés agregarla desde tu perfil.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // 🔥 PRINTS PARA DEPURAR
            (() {
              print('>>> Intentando cargar icono: assets/icon/icon.png');
              return Image.asset(
                'assets/icon/icon.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  print('>>> ERROR al cargar icono: $error');
                  return const Icon(
                    Icons.error,
                    size: 80,
                    color: Colors.red,
                  );
                },
              );
            })(),
            const SizedBox(height: 20),

            // 🔥 SELECTOR DE FOTO DE PERFIL (OBLIGATORIO)
            GestureDetector(
              onTap: _mostrarOpcionesFoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      border: Border.all(
                        color: _fotoPerfil == null
                            ? Colors.red.shade300
                            : Colors.blue,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: _fotoPerfil != null
                          ? Image.file(_fotoPerfil!, fit: BoxFit.cover)
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey.shade500,
                            ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _fotoPerfil == null
                  ? 'Foto de perfil obligatoria'
                  : 'Cambiar foto',
              style: TextStyle(
                fontSize: 12,
                color: _fotoPerfil == null ? Colors.red : Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // 🔥 CHECKBOX DE CONSENTIMIENTO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _aceptaRecoleccionDatos,
                  onChanged: (value) {
                    setState(() {
                      _aceptaRecoleccionDatos = value ?? false;
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

            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Registrarse'),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('¿Ya tienes cuenta? Inicia sesión'),
            ),
            ],
          ),
        ),
      ),
    );
  }
}