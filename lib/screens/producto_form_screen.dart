import 'package:flutter/material.dart';
import '../widgets/rewarded_ad_prueba.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class ProductoFormScreen extends StatefulWidget {
  final String categoria;
  final String subcategoria;
  final String direccion;
  final XFile? imagenDestacada;
  final List<XFile> imagenesReales;

  const ProductoFormScreen({
    super.key,
    required this.categoria,
    required this.subcategoria,
    required this.direccion,
    this.imagenDestacada,
    this.imagenesReales = const [],
  });

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _publicando = false;

  @override
  void initState() {
    super.initState();
    // 🔥 Cargar el anuncio recompensado al entrar
    RewardedAdManager.loadRewardedAd();
  }

  // ============ 🔥 MOSTRAR POPUP DE ANUNCIO PARA PUBLICAR ============
  void _mostrarPopupAnuncioPublicar() {
    // Validar formulario primero
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(  // 🔥 PARA EVITAR OVERFLOW
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),  // 🔥 MENOS PADDING
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storefront,
                    size: 40,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Publicar Producto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Para publicar tu producto, necesitas ver un breve anuncio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _verAnuncioYPublicar();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_filled, size: 18),
                            SizedBox(width: 6),
                            Text('Ver anuncio', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============ 🔥 VER ANUNCIO Y PUBLICAR ============
  void _verAnuncioYPublicar() {
    print('>>> 1. ENTRE A _verAnuncioYPublicar()');

    if (!RewardedAdManager.isAdLoaded) {
      print('>>> 2. Anuncio NO cargado, cargando...');
      RewardedAdManager.loadRewardedAd();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Cargando anuncio... espera un momento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('>>> 3. Anuncio cargado, mostrando...');
    RewardedAdManager.showRewardedAd(
      onRewarded: () {
        print('>>> 4. ✅ USUARIO GANÓ RECOMPENSA');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Anuncio completado. Publicando producto...'),
            backgroundColor: Colors.green,
          ),
        );
        print('>>> 5. Llamando a _publicarProducto()');
        _publicarProducto();
      },
      onDismissed: () {
        print('>>> 6. ❌ Anuncio cerrado SIN recompensa');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Debes ver el anuncio completo para publicar'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
    print('>>> 7. SALI DE _verAnuncioYPublicar()');
  }

  // ============ 🔥 PUBLICAR PRODUCTO ============
  Future<void> _publicarProducto() async {
    print('>>> 🚀 ENTRE A _publicarProducto');

    if (_publicando) return;
    setState(() => _publicando = true);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://mimarketplace-production.up.railway.app/api/productos'),
      );

      request.fields['nombre'] = _nombreController.text;
      request.fields['precio'] = _precioController.text;
      request.fields['descripcion'] = _descripcionController.text;
      request.fields['categoria'] = widget.categoria;
      request.fields['subcategoria'] = widget.subcategoria;
      request.fields['vendedor_id'] = FirebaseAuth.instance.currentUser?.uid ?? '';
      request.fields['direccion'] = widget.direccion;

      // ===== IMAGEN DESTACADA =====
      if (widget.imagenDestacada != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen_destacada',
            widget.imagenDestacada!.path,
          ),
        );
      }

      // ===== IMÁGENES REALES =====
      for (var imagen in widget.imagenesReales) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagenes_reales[]',
            imagen.path,
          ),
        );
      }

      print('>>> Enviando producto a la API...');
      final response = await request.send();
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        print('>>> ✅ Producto enviado para moderación: ${data['mensaje']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📝 Producto enviado para revisión. Recibirás una notificación cuando sea aprobado.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        // Volver al home
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        throw Exception('Error al publicar');
      }
    } catch (e) {
      print('>>> ❌ ERROR AL PUBLICAR: $e');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _publicando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Producto'),
        backgroundColor: const Color(0xFF087FE8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInfoRow('Categoría', widget.categoria),
              const SizedBox(height: 12),
              _buildInfoRow('Subcategoría', widget.subcategoria),
              const SizedBox(height: 12),
              _buildInfoRow('Dirección', widget.direccion),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio (₡)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el precio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _publicando ? null : _mostrarPopupAnuncioPublicar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF087FE8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _publicando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Publicar Producto',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}