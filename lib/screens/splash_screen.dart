import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _videoListo = false;

  @override
  void initState() {
    super.initState();
    _iniciarVideo();
  }

  Future<void> _iniciarVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/inicio.mp4');

    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.setVolume(0); // sin sonido
      await _controller.play();

      setState(() => _videoListo = true);

      // 🔥 Cuando termina el video, navega al AuthGate
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          _irAlLogin();
        }
      });
    } catch (e) {
      print('>>> ❌ Error al cargar el video: $e');
      // Si falla el video, va directo al login después de 1 segundo
      await Future.delayed(const Duration(seconds: 1));
      _irAlLogin();
    }
  }

  void _irAlLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _videoListo
          ? Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}