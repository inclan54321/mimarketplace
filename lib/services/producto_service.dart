import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class ProductoService {
  static const String baseUrl = 'http://192.168.100.248:3000';

  Future<List<Producto>> getProductosByCategoria(String categoria, {List<String>? bloqueados}) async {
    try {
      // ✅ RUTA CORRECTA CON /categoria/ EN LA URL
      final response = await http.get(
        Uri.parse('$baseUrl/api/productos/categoria/$categoria'),
      );

      print('>>> RESPONSE STATUS: ${response.statusCode}');
      print('>>> RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        
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