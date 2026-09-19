class Calificacion {
  final int id;
  final String usuarioId;
  final String calificadorId;
  final int productoId;
  final int puntuacion;
  final String comentario;
  final DateTime fecha;
  final String? calificadorNombre;
  final String? calificadorFoto;

  Calificacion({
    required this.id,
    required this.usuarioId,
    required this.calificadorId,
    required this.productoId,
    required this.puntuacion,
    required this.comentario,
    required this.fecha,
    this.calificadorNombre,
    this.calificadorFoto,
  });

  factory Calificacion.fromJson(Map<String, dynamic> json) {
    return Calificacion(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'] ?? '',
      calificadorId: json['calificador_id'] ?? '',
      productoId: json['producto_id'] ?? 0,
      puntuacion: json['puntuacion'] ?? 0,
      comentario: json['comentario'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      calificadorNombre: json['calificador_nombre'],
      calificadorFoto: json['calificador_foto'],
    );
  }
}