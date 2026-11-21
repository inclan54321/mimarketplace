import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/producto.dart';

class ProductoService {
  static const String baseUrl = 'https://mimarketplace-production.up.railway.app';

  // 🔥 Caché en memoria por categoría (se borra al cerrar la app)
  static final Map<String, List<Producto>> _cacheCategorias = {};

  List<Producto>? categoriaEnCache(String categoria, {List<String>? bloqueados}) {
    final c = _cacheCategorias[categoria];
    if (c == null) return null;
    if (bloqueados == null || bloqueados.isEmpty) return c;
    return c.where((p) => !bloqueados.contains(p.vendedorId ?? '')).toList();
  }

  Future<List<Producto>> getProductosByCategoria(String categoria, {List<String>? bloqueados}) async {
    try {
      // ✅ RUTA CORRECTA CON /categoria/ EN LA URL (con token)
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/productos/categoria/${Uri.encodeComponent(categoria)}'),
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      print('>>> RESPONSE STATUS: ${response.statusCode}');


      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _cacheCategorias[categoria] =
            data.map((json) => Producto.fromJson(json)).toList();

        if (bloqueados != null && bloqueados.isNotEmpty) {
          final filtrados = data.where((p) {
            final vendedorId = p['vendedor_id']?.toString() ?? '';
            return !bloqueados.contains(vendedorId);
          }).toList();
          return filtrados.map((json) => Producto.fromJson(json)).toList();
        }
        
        return data.map((json) => Producto.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener productos por categoría: $e');
      return [];
    }
  }

  Future<List<Producto>> getProductosByVendedor(String vendedorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/productos/vendedor/$vendedorId'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos del vendedor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}