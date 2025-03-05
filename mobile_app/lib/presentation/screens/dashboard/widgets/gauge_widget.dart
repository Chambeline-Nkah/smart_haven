// lib/presentation/widgets/sensor_gauge.dart
import 'dart:math';
import 'package:flutter/material.dart';

enum SensorType {
  temperature,
  humidity
}

class SensorGauge extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final IconData icon;
  final SensorType type;

  const SensorGauge({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.type,
  }) : super(key: key);

  Color _getColorForTemperature(double temp) {
    if (temp >= 23 && temp <= 37) return Colors.green;
    if (temp > 37 && temp <= 44) return Colors.orange;
    return Colors.red; // for temp < 23 or temp > 44
  }

  Color _getColorForHumidity(double humidity) {
    if (humidity <= 20) return Colors.red;
    if (humidity > 20 && humidity <= 40) return Colors.green;
    if (humidity > 40 && humidity <= 60) return Colors.orange;
    return Colors.red; // for humidity > 60
  }

  double _getPercentageForValue() {
    switch (type) {
      case SensorType.temperature:
        // Map temperature range (0-50) to percentage
        return (value.clamp(0, 50)) / 50;
      case SensorType.humidity:
        // Map humidity range (0-100) to percentage
        return (value.clamp(0, 100)) / 100;
    }
  }

  Color _getColor() {
    switch (type) {
      case SensorType.temperature:
        return _getColorForTemperature(value);
      case SensorType.humidity:
        return _getColorForHumidity(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final percentage = _getPercentageForValue();

    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          CustomPaint(
            size: const Size(150, 75),
            painter: GaugePainter(
              percentage: percentage,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                ),
              ),
              Text(
                unit,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          Icon(icon, color: color, size: 24),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  GaugePainter({
    required this.percentage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    
    // Draw background arc
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    // Draw value arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * percentage,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}