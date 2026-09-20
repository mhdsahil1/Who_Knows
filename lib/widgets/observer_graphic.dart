import 'package:flutter/material.dart';
import '../theme/wk_colors.dart';

/// The brand's recurring visual character — an abstract geometric eye.
///
/// A mysterious observer composed of two overlapping arcs with a
/// drifting circular pupil. Communicates "someone is watching."
class ObserverGraphic extends StatefulWidget {
  final double size;
  final Color color;
  final bool animate;

  const ObserverGraphic({
    super.key,
    this.size = 200,
    this.color = WKColors.offWhite,
    this.animate = true,
  });

  @override
  State<ObserverGraphic> createState() => _ObserverGraphicState();
}

class _ObserverGraphicState extends State<ObserverGraphic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathe;
  late Animation<double> _pupilDrift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _breathe = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _pupilDrift = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ObserverPainter(
            color: widget.color,
            scale: 1.0,
            pupilOffset: 0.0,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ObserverPainter(
              color: widget.color,
              scale: _breathe.value,
              pupilOffset: _pupilDrift.value,
            ),
          ),
        );
      },
    );
  }
}

class _ObserverPainter extends CustomPainter {
  final Color color;
  final double scale;
  final double pupilOffset;

  _ObserverPainter({
    required this.color,
    required this.scale,
    required this.pupilOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final eyeWidth = size.width * 0.42 * scale;
    final eyeHeight = size.height * 0.22 * scale;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round;

    // Upper arc of the eye
    final upperPath = Path();
    upperPath.moveTo(center.dx - eyeWidth, center.dy);
    upperPath.quadraticBezierTo(
      center.dx,
      center.dy - eyeHeight * 1.8,
      center.dx + eyeWidth,
      center.dy,
    );
    canvas.drawPath(upperPath, paint);

    // Lower arc of the eye
    final lowerPath = Path();
    lowerPath.moveTo(center.dx - eyeWidth, center.dy);
    lowerPath.quadraticBezierTo(
      center.dx,
      center.dy + eyeHeight * 1.8,
      center.dx + eyeWidth,
      center.dy,
    );
    canvas.drawPath(lowerPath, paint);

    // Iris circle
    final irisPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.015;
    final irisRadius = eyeHeight * 0.8;
    final irisCenter = Offset(
      center.dx + pupilOffset * eyeWidth,
      center.dy,
    );
    canvas.drawCircle(irisCenter, irisRadius, irisPaint);

    // Pupil (filled)
    final pupilPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final pupilRadius = irisRadius * 0.4;
    canvas.drawCircle(irisCenter, pupilRadius, pupilPaint);

    // Question mark shadow beneath the eye
    final qPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;

    final qTop = center.dy + eyeHeight * 2.2;
    final qPath = Path();
    qPath.moveTo(center.dx - eyeWidth * 0.2, qTop);
    qPath.quadraticBezierTo(
      center.dx + eyeWidth * 0.25,
      qTop,
      center.dx + eyeWidth * 0.15,
      qTop + size.height * 0.06,
    );
    qPath.quadraticBezierTo(
      center.dx,
      qTop + size.height * 0.1,
      center.dx,
      qTop + size.height * 0.13,
    );
    canvas.drawPath(qPath, qPaint);

    // Dot under question mark
    canvas.drawCircle(
      Offset(center.dx, qTop + size.height * 0.18),
      size.width * 0.012,
      Paint()..color = color.withValues(alpha: 0.15),
    );
  }

  @override
  bool shouldRepaint(_ObserverPainter oldDelegate) =>
      oldDelegate.scale != scale ||
      oldDelegate.pupilOffset != pupilOffset ||
      oldDelegate.color != color;
}
