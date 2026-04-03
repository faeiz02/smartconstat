import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

enum StrokeType { freehand, line, circle }

abstract class SmartStroke {
  final StrokeType type;
  final Color color;
  final double strokeWidth;
  SmartStroke(this.type, this.color, this.strokeWidth);
  void draw(Canvas canvas, Paint paint);
}

class FreehandStroke extends SmartStroke {
  final List<Offset> points;
  FreehandStroke(this.points, Color color, double strokeWidth)
      : super(StrokeType.freehand, color, strokeWidth);

  @override
  void draw(Canvas canvas, Paint paint) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
        path,
        paint
          ..color = color
          ..strokeWidth = strokeWidth);
  }
}

class LineStroke extends SmartStroke {
  final Offset start;
  final Offset end;
  LineStroke(this.start, this.end, Color color, double strokeWidth)
      : super(StrokeType.line, color, strokeWidth);

  @override
  void draw(Canvas canvas, Paint paint) {
    canvas.drawLine(
        start,
        end,
        paint
          ..color = color
          ..strokeWidth = strokeWidth);
  }
}

class CircleStroke extends SmartStroke {
  final Offset center;
  final double radius;
  CircleStroke(this.center, this.radius, Color color, double strokeWidth)
      : super(StrokeType.circle, color, strokeWidth);

  @override
  void draw(Canvas canvas, Paint paint) {
    canvas.drawCircle(
        center,
        radius,
        paint
          ..color = color
          ..strokeWidth = strokeWidth);
  }
}

class SmartCanvasController extends ChangeNotifier {
  final List<SmartStroke> strokes = [];
  bool get isEmpty => strokes.isEmpty;

  void addStroke(SmartStroke stroke) {
    strokes.add(stroke);
    notifyListeners();
  }

  void clear() {
    strokes.clear();
    notifyListeners();
  }

  Future<Uint8List?> toPngBytes() async {
    if (strokes.isEmpty) return null;
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
          recorder, const Rect.fromLTWH(0, 0, 1000, 1000)); // Large canvas size

      canvas.drawRect(
          const Rect.fromLTWH(0, 0, 1000, 1000), Paint()..color = Colors.white);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (var stroke in strokes) {
        stroke.draw(canvas, paint);
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(1000, 1000);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Erreur export PNG: $e");
      return null;
    }
  }
}

class SmartCanvasWidget extends StatefulWidget {
  final SmartCanvasController controller;
  final double height;

  const SmartCanvasWidget(
      {super.key, required this.controller, this.height = 300});

  @override
  State<SmartCanvasWidget> createState() => _SmartCanvasWidgetState();
}

class _SmartCanvasWidgetState extends State<SmartCanvasWidget> {
  List<Offset> _currentPoints = [];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentPoints = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPoints.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPoints.length < 3) {
      _currentPoints = [];
      return;
    }

    // ─── SHAPE RECOGNITION ALGORITHM ─── //
    final stroke = _analyzeStroke(_currentPoints);
    widget.controller.addStroke(stroke);

    setState(() {
      _currentPoints = [];
    });
  }

  SmartStroke _analyzeStroke(List<Offset> pts) {
    final start = pts.first;
    final end = pts.last;

    // Bounds calculation
    double minX = pts.first.dx, maxX = pts.first.dx;
    double minY = pts.first.dy, maxY = pts.first.dy;

    for (var p in pts) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    double width = maxX - minX;
    double height = maxY - minY;
    double diagonal = sqrt(width * width + height * height);
    double startToEndDist = (start - end).distance;

    // 1. Cercle (Test)
    // Si la distance début->fin est petite et la box est relativement carrée
    if (startToEndDist < diagonal * 0.25) {
      double aspectRatio = width > height ? width / height : height / width;
      if (aspectRatio < 1.4) {
        final center = Offset(minX + width / 2, minY + height / 2);
        final radius = (width + height) / 4;
        return CircleStroke(center, radius, Colors.blue, 3.0);
      }
    }

    // 2. Ligne Droite (Test)
    // Mesurer la déviation maximale du tracé par rapport à la ligne théorique
    double maxDeviation = 0;
    double lineLength = (end - start).distance;

    if (lineLength > 30) {
      for (var p in pts) {
        double dist = _distanceToLine(p, start, end);
        if (dist > maxDeviation) maxDeviation = dist;
      }

      // Si l'écart moyen avec la ligne parfaite est très faible -> Ligne géométrique
      if (maxDeviation < lineLength * 0.15) {
        return LineStroke(start, end, Colors.black, 3.0);
      }
    }

    // 3. Dessin Libre
    return FreehandStroke(List.from(pts), Colors.black, 3.0);
  }

  double _distanceToLine(Offset p, Offset a, Offset b) {
    double num = ((b.dy - a.dy) * p.dx -
            (b.dx - a.dx) * p.dy +
            b.dx * a.dy -
            b.dy * a.dx)
        .abs();
    double den = sqrt(pow(b.dy - a.dy, 2) + pow(b.dx - a.dx, 2));
    if (den == 0) return 0;
    return num / den;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        height: widget.height,
        color: Colors.white,
        child: CustomPaint(
          size: Size.infinite,
          painter: _SmartPainter(widget.controller, _currentPoints),
        ),
      ),
    );
  }
}

class _SmartPainter extends CustomPainter {
  final SmartCanvasController controller;
  final List<Offset> currentPoints;

  _SmartPainter(this.controller, this.currentPoints)
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var stroke in controller.strokes) {
      stroke.draw(canvas, paint);
    }

    // Dessiner le tracé en cours de survol
    if (currentPoints.length >= 2) {
      final path = Path()
        ..moveTo(currentPoints.first.dx, currentPoints.first.dy);
      for (int i = 1; i < currentPoints.length; i++) {
        path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
      }
      canvas.drawPath(
          path,
          paint
            ..color = Colors.grey
            ..strokeWidth = 3.0);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
