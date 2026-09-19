class Producto {
  final int id;
  final String nombre;
  final String categoria;
  final double precio;
  final String? imagenUrl;
  final String descripcion;
  final String direccion;
  final String? vendedorNombre;
  final String? vendedorFoto;
  final String? vendedorId;
  final String? provincia;
  final String? imagenDestacada;
  final String? imagenesReales;
  final String? estadoModeracion;
  final String? motivoRechazo;
  final int likes;
  final int? vistas;
  final String? imagenMiniatura; // 🔥 NUEVO

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    this.imagenUrl,
    required this.descripcion,
    required this.direccion,
    this.vendedorNombre,
    this.vendedorFoto,
    this.vendedorId,
    this.provincia,
    this.imagenDestacada,
    this.imagenesReales,
    this.estadoModeracion,
    this.motivoRechazo,
    this.likes = 0,
    this.vistas = 0,
    this.imagenMiniatura, // 🔥 NUEVO
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      precio: double.parse(json['precio']?.toString() ?? '0'),
      imagenUrl: json['imagen_url'],
      descripcion: json['descripcion'] ?? '',
      direccion: json['direccion'] ?? '',
      vendedorNombre: json['vendedor_nombre'] ?? '',
      vendedorFoto: json['vendedor_foto'] ?? '',
      vendedorId: json['vendedor_id'] ?? '',
      provincia: json['provincia'] ?? '',
      imagenDestacada: json['imagen_destacada'],
      imagenesReales: json['imagenes_reales'],
      likes: json['likes'] ?? 0,
      vistas: json['total_vistas'] ?? json['vistas'] ?? 0,
      imagenMiniatura: json['imagen_miniatura'] ?? '', // 🔥 NUEVO
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'imagen_url': imagenUrl,
      'descripcion': descripcion,
      'direccion': direccion,
      'vendedor_nombre': vendedorNombre,
      'vendedor_foto': vendedorFoto,
      'vendedor_id': vendedorId,
      'provincia': provincia,
      'imagen_destacada': imagenDestacada,
      'imagenes_reales': imagenesReales,
      'likes': likes,
      'vistas': vistas,
      'imagen_miniatura': imagenMiniatura, // 🔥 NUEVO
    };
  }
}