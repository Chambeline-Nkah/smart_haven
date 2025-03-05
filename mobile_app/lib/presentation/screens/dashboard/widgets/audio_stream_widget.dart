// lib/presentation/widgets/live_feed.dart
import 'dart:async';
import 'package:flutter/material.dart';

class LiveFeedSpectrogram extends StatefulWidget {
  const LiveFeedSpectrogram({Key? key}) : super(key: key);

  @override
  State<LiveFeedSpectrogram> createState() => _LiveFeedSpectrogramState();
}

class _LiveFeedSpectrogramState extends State<LiveFeedSpectrogram> {
  final List<double> _audioData = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startStreamSimulation();
  }

  void _startStreamSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          // Simulate audio data (replace with real data from your endpoint)
          _audioData.add(0.5 + (DateTime.now().millisecondsSinceEpoch % 100) / 200);
          if (_audioData.length > 100) _audioData.removeAt(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: SpectrogramPainter(audioData: _audioData),
        size: const Size(double.infinity, 200),
      ),
    );
  }
}

class SpectrogramPainter extends CustomPainter {
  final List<double> audioData;

  SpectrogramPainter({required this.audioData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (audioData.isEmpty) return;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final pointWidth = width / (audioData.length - 1);

    path.moveTo(0, height * (1 - audioData.first));

    for (var i = 1; i < audioData.length; i++) {
      path.lineTo(pointWidth * i, height * (1 - audioData[i]));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}