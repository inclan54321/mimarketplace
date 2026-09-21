import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await credential.user?.updateDisplayName(_nameController.text.trim());

      // 🔥 ENVIAR EL CAMPO DE CONSENTIMIENTO AL BACKEND
      final response = await http.post(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': credential.user?.uid,
          'email': _emailController.text.trim(),
          'nombre': _nameController.text.trim(),
          'telefono': _phoneController.text.trim(),
          'acepta_recoleccion': _aceptaRecoleccionDatos, // 🔥 NUEVO CAMPO
        }),
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
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
    );
  }
}