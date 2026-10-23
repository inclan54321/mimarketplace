import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class PantallaVerificarIdentidadOtro extends StatefulWidget {
  final int encuentroId;

  const PantallaVerificarIdentidadOtro({super.key, required this.encuentroId});

  @override
  State<PantallaVerificarIdentidadOtro> createState() =>
      _PantallaVerificarIdentidadOtroState();
}

class _PantallaVerificarIdentidadOtroState
    extends State<PantallaVerificarIdentidadOtro> {
  static const String _baseUrl =
      'https://mimarketplace-production.up.railway.app';

  bool _cargando = true;
  String? _error;
  Map<String, dynamic>? _datos;
  String? _selfieUrl;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken();

      // Datos del encuentro (incluye foto del otro)
      final r = await http.get(
        Uri.parse('$_baseUrl/api/encuentro/${widget.encuentroId}/datos?usuario_id=${user.uid}'),
        headers: {if (idToken != null) 'Authorization': 'Bearer $idToken'},
      );
      if (r.statusCode != 200) {
        setState(() {
          _error = 'No se pudo cargar el encuentro';
          _cargando = false;
        });
        return;
      }
      _datos = jsonDecode(r.body) as Map<String, dynamic>;
      final otroId = _datos!['otro_usuario_id'] ?? '';

      // Selfie del otro
      final r2 = await http.get(
        Uri.parse('$_baseUrl/api/encuentro/${widget.encuentroId}/selfie/$otroId'),
        headers: {if (idToken != null) 'Authorization': 'Bearer $idToken'},
      );
      if (r2.statusCode == 200) {
        final data2 = jsonDecode(r2.body) as Map<String, dynamic>;
        _selfieUrl = data2['selfie_url'];
      }

      setState(() => _cargando = false);
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _cargando = false;
      });
    }
  }

  Future<void> _confirmar() async {
    setState(() => _enviando = true);
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final r = await http.post(
        Uri.parse('$_baseUrl/api/encuentro/${widget.encuentroId}/confirmar-identidad'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final ambos = data['ambos_confirmaron'] == true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ambos
                  ? '✅ Ambos confirmaron. Chat desbloqueado.'
                  : '✅ Confirmaste. Esperando al otro usuario...'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _rechazar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Rechazar identidad?'),
        content: const Text(
          'Si rechazás, el trato se cancelará para ambos y el chat quedará cerrado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, rechazar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _enviando = true);
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      await http.post(
        Uri.parse('$_baseUrl/api/encuentro/${widget.encuentroId}/rechazar-identidad'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Trato cancelado.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar identidad'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _construirContenido(),
    );
  }

  Widget _construirContenido() {
    final otroNombre = _datos?['otro_usuario_nombre'] ?? 'El otro usuario';
    final fotoPerfil = _datos?['otro_usuario_foto'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            '¿Son la misma persona?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Compará la foto de perfil de $otroNombre con la selfie que se tomó hoy.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _tarjetaFoto('Foto de perfil', fotoPerfil, false)),
                const SizedBox(width: 12),
                Expanded(
                  child: _tarjetaFoto('Selfie de hoy', _selfieUrl ?? '', true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _enviando ? null : _rechazar,
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text(
                    'No coincide',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _enviando ? null : _confirmar,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Sí, es la misma'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaFoto(String label, String url, bool esSelfie) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: esSelfie ? Colors.green : Colors.blue,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: url.isEmpty
                ? const Center(child: Icon(Icons.person, size: 64, color: Colors.grey))
                : CachedNetworkImage(
                    imageUrl: '$_baseUrl$url',
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, _, _) => const Center(
                      child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}