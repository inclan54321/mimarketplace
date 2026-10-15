import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatWebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final String conversacionId;
  final String usuarioId;

  bool _activo = false;
  int _intentosReconexion = 0;

  // Callbacks
  final void Function(Map<String, dynamic> data)? onNuevoMensaje;
  final void Function(Map<String, dynamic> data)? onEstadoCambio;
  final void Function()? onConectado;
  final void Function()? onDesconectado;

  ChatWebSocketService({
    required this.conversacionId,
    required this.usuarioId,
    this.onNuevoMensaje,
    this.onEstadoCambio,
    this.onConectado,
    this.onDesconectado,
  });

  static const String _baseUrl =
      'wss://mimarketplace-production.up.railway.app/ws/chat';

  void conectar() {
    if (_activo) return;
    _activo = true;
    _abrir();
  }

  void _abrir() {
    try {
      final uri = Uri.parse(
        '$_baseUrl?conversacion_id=$conversacionId&usuario_id=$usuarioId',
      );
      _channel = WebSocketChannel.connect(uri);

      _sub = _channel!.stream.listen(
        (raw) {
          _intentosReconexion = 0;
          try {
            final data = jsonDecode(raw) as Map<String, dynamic>;
            final tipo = data['tipo'] as String?;
            switch (tipo) {
              case 'nuevo_mensaje':
                onNuevoMensaje?.call(data);
                break;
              case 'estado_cambio':
                onEstadoCambio?.call(data);
                break;
              case 'conectado':
                onConectado?.call();
                break;
            }
          } catch (e) {
            print('>>> WS parse error: $e');
          }
        },
        onDone: _onClose,
        onError: (e) {
          print('>>> WS error: $e');
          _onClose();
        },
      );

      // Ping cada 30s para mantener viva la conexión
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        try {
          _channel?.sink.add(jsonEncode({'tipo': 'ping'}));
        } catch (_) {}
      });

      print('>>> 🔌 WS conectado a $conversacionId');
    } catch (e) {
      print('>>> WS connect error: $e');
      _programarReconexion();
    }
  }

  void _onClose() {
    _pingTimer?.cancel();
    _sub?.cancel();
    _channel = null;

    if (!_activo) return;
    onDesconectado?.call();
    _programarReconexion();
  }

  void _programarReconexion() {
    if (!_activo) return;
    _reconnectTimer?.cancel();
    // backoff exponencial: 1s, 2s, 4s, 8s, máximo 30s
    final segundos = (1 << _intentosReconexion).clamp(1, 30);
    _intentosReconexion = (_intentosReconexion + 1).clamp(0, 5);
    print('>>> WS reintentando en ${segundos}s');
    _reconnectTimer = Timer(Duration(seconds: segundos), _abrir);
  }

  void enviar(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (e) {
      print('>>> WS send error: $e');
    }
  }

  void desconectar() {
    _activo = false;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _sub?.cancel();
    try {
      _channel?.sink.close(status.goingAway);
    } catch (_) {}
    _channel = null;
    print('>>> 🔌 WS desconectado');
  }
}