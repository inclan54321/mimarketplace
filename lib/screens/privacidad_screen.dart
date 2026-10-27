import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'historial_pagos_screen.dart';

class PrivacidadScreen extends StatefulWidget {
  const PrivacidadScreen({super.key});

  @override
  State<PrivacidadScreen> createState() => _PrivacidadScreenState();
}

class _PrivacidadScreenState extends State<PrivacidadScreen> {
  bool _aceptaRecoleccion = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // 🔥 ESTADO DE CUENTA (advertencias y suspensiones)
  int _advertencias = 0;
  int _suspensiones = 0;
  static const int _maxAdvertencias = 3;
  static const int _maxSuspensiones = 3;

  // 🔥 CONTACTOS DE EMERGENCIA
  List<Map<String, String>> _contactosEmergencia = [];

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
    _cargarContactosEmergencia();
  }

  Future<void> _cargarPreferencias() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

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
          _aceptaRecoleccion = data['acepta_recoleccion'] ?? false;
          _isLoading = false;
        });
      }

      // 🔥 Cargar estado de cuenta (advertencias y suspensiones)
      await _cargarEstadoCuenta();
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

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.put(
        Uri.parse('https://mimarketplace-production.up.railway.app/api/usuarios/${user.uid}'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
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

  // 🔥 CARGAR ESTADO DE CUENTA (ADVERTENCIAS Y SUSPENSIONES)
  Future<void> _cargarEstadoCuenta() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse(
            'https://mimarketplace-production.up.railway.app/api/usuarios/${user.uid}/estado-cuenta'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _advertencias = int.tryParse(data['advertencias']?.toString() ?? '0') ?? 0;
          _suspensiones = int.tryParse(data['suspensiones']?.toString() ?? '0') ?? 0;
        });
      }
    } catch (e) {
      // Si falla, dejamos los contadores en 0 sin romper la pantalla
      print('Error al cargar estado de cuenta: $e');
    }
  }

  // 🔥 MOSTRAR INFO DEL ESTADO DE CUENTA
  void _mostrarInfoEstadoCuenta() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(child: Text('Estado de cuenta')),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Cómo funciona?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Tu cuenta acumula advertencias y suspensiones temporales por incumplir las normas de la comunidad.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Advertencias (máx. 3): se generan por reportes leves como lenguaje inapropiado, publicaciones con información engañosa o incumplimiento menor de las reglas. No bloquean tu cuenta.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_clock, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Suspensiones temporales (máx. 3): se aplican por faltas más graves como estafas, acoso, suplantación de identidad o reincidencia en advertencias. Cada suspensión bloquea tu cuenta por un período.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Text(
                'Si llegás a 3 suspensiones, tu cuenta puede ser inhabilitada permanentemente.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔥 CONTACTOS DE EMERGENCIA
  // ============================================================
  Future<void> _cargarContactosEmergencia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('contactos_emergencia');
      if (raw == null || raw.isEmpty) return;
      final List data = jsonDecode(raw);
      if (mounted) {
        setState(() {
          _contactosEmergencia = data
              .map((e) => Map<String, String>.from(e as Map))
              .toList();
        });
      }
    } catch (e) {
      print('Error al cargar contactos de emergencia: $e');
    }
  }

  Future<void> _guardarContactosEmergencia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'contactos_emergencia',
        jsonEncode(_contactosEmergencia),
      );
    } catch (e) {
      print('Error al guardar contactos de emergencia: $e');
    }
  }

  void _mostrarDialogoAgregarContacto({int? indexEditar}) {
    final nombreCtrl = TextEditingController(
      text: indexEditar != null
          ? _contactosEmergencia[indexEditar]['nombre'] ?? ''
          : '',
    );
    final numeroCtrl = TextEditingController(
      text: indexEditar != null
          ? _contactosEmergencia[indexEditar]['numero'] ?? ''
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                indexEditar == null
                    ? 'Agregar contacto de emergencia'
                    : 'Editar contacto de emergencia',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej: Mamá, Papá, Hermano',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: numeroCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Número de teléfono',
                hintText: 'Ej: 8888-8888',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final numero = numeroCtrl.text.trim();
              if (nombre.isEmpty || numero.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completá nombre y número'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              setState(() {
                if (indexEditar == null) {
                  _contactosEmergencia.add({
                    'nombre': nombre,
                    'numero': numero,
                  });
                } else {
                  _contactosEmergencia[indexEditar] = {
                    'nombre': nombre,
                    'numero': numero,
                  };
                }
              });
              await _guardarContactosEmergencia();

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      indexEditar == null
                          ? '✅ Contacto agregado'
                          : '✅ Contacto actualizado',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.save, size: 18),
            label: Text(indexEditar == null ? 'Agregar' : 'Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarContactoEmergencia(int index) async {
    final contacto = _contactosEmergencia[index];
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar contacto?'),
        content: Text(
          'Se eliminará "${contacto['nombre']}" de tus contactos de emergencia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _contactosEmergencia.removeAt(index);
    });
    await _guardarContactosEmergencia();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Contacto eliminado'),
          backgroundColor: Colors.grey,
        ),
      );
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
        child: SingleChildScrollView(
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
            // 🔥 NUEVA SECCIÓN: HISTORIAL DE PAGOS
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Historial de pagos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Consultá todos los pagos que hiciste dentro de la app: impulsos de publicaciones, renovaciones, eliminación de publicidad y otros servicios.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.blue,
                ),
              ),
              title: const Text(
                'Ver historial de pagos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Todos tus pagos y transacciones',
                style: TextStyle(fontSize: 13),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistorialPagosScreen(),
                  ),
                );
              },
            ),

            // 🔥 NUEVA SECCIÓN: ESTADO DE CUENTA
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Estado de cuenta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Revisá tus advertencias y suspensiones activas en la plataforma.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // 🔥 TARJETA: ADVERTENCIAS
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Advertencias',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$_advertencias/$_maxAdvertencias',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _advertencias >= _maxAdvertencias
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 TARJETA: SUSPENSIONES TEMPORALES
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_clock,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Suspensiones temporales',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$_suspensiones/$_maxSuspensiones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _suspensiones >= _maxSuspensiones
                          ? Colors.red
                          : Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 BOTÓN: INFORMACIÓN
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _mostrarInfoEstadoCuenta,
                icon: const Icon(Icons.info_outline, size: 20),
                label: const Text(
                  'Información',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // 🔥 NUEVA SECCIÓN: LLAMADA DE EMERGENCIA
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Llamada de emergencia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agregá los nombres y números de las personas que querés que aparezcan en tu pantalla de emergencia. Podrás llamarlas rápido desde cualquier chat con el Escudo activo.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // 🔥 LISTA DE CONTACTOS
            if (_contactosEmergencia.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.contacts_outlined,
                      size: 40,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No tenés contactos de emergencia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Agregá al menos uno para usarlo desde el chat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_contactosEmergencia.length, (i) {
                final c = _contactosEmergencia[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['nombre'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c['numero'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _mostrarDialogoAgregarContacto(indexEditar: i),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _eliminarContactoEmergencia(i),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                );
              }),

            // 🔥 BOTÓN AGREGAR
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _mostrarDialogoAgregarContacto(),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Agregar contacto',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}