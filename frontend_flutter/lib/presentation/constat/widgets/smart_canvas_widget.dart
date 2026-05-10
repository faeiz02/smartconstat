import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../screens/fullscreen_canvas_screen.dart';

// ══════════════════════════════════════════════════════════════════════
// DRAWING TOOL TYPES
// ══════════════════════════════════════════════════════════════════════
enum DrawingTool {
  pen,
  line,
  rectangle,
  circle,
  arrow,
  carA,
  carB,
  sign,
  text,
  eraser,
  move
}

// ══════════════════════════════════════════════════════════════════════
// STROKE MODELS
// ══════════════════════════════════════════════════════════════════════
abstract class DrawingElement {
  final Color color;
  final double strokeWidth;
  DrawingElement(this.color, this.strokeWidth);
  void draw(Canvas canvas, Size size);
}

class PenStroke extends DrawingElement {
  final List<Offset> points;
  PenStroke(this.points, Color color, double strokeWidth)
      : super(color, strokeWidth);

  @override
  void draw(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Smooth the points using Catmull-Rom spline
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    if (points.length == 2) {
      path.lineTo(points[1].dx, points[1].dy);
    } else {
      for (int i = 1; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        final midY = (p0.dy + p1.dy) / 2;
        path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
      }
      path.lineTo(points.last.dx, points.last.dy);
    }

    canvas.drawPath(path, paint);
  }
}

class LineDraw extends DrawingElement {
  Offset start;
  Offset end;
  LineDraw(this.start, this.end, Color color, double strokeWidth)
      : super(color, strokeWidth);

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }
}

class ArrowDraw extends DrawingElement {
  Offset start;
  Offset end;
  ArrowDraw(this.start, this.end, Color color, double strokeWidth)
      : super(color, strokeWidth);

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);

    // Arrowhead
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    const arrowSize = 14.0;
    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(end.dx - arrowSize * cos(angle - 0.5),
        end.dy - arrowSize * sin(angle - 0.5));
    path.moveTo(end.dx, end.dy);
    path.lineTo(end.dx - arrowSize * cos(angle + 0.5),
        end.dy - arrowSize * sin(angle + 0.5));
    canvas.drawPath(path, paint..strokeWidth = strokeWidth + 1);
  }
}

class RectDraw extends DrawingElement {
  Rect rect;
  RectDraw(this.rect, Color color, double strokeWidth)
      : super(color, strokeWidth);

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }
}

class CircleDraw extends DrawingElement {
  Offset center;
  double radius;
  CircleDraw(this.center, this.radius, Color color, double strokeWidth)
      : super(color, strokeWidth);

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);
  }
}

class CarStamp extends DrawingElement {
  Offset position;
  final String label; // "A" or "B"
  final double angle;
  CarStamp(this.position, this.label, this.angle, Color color)
      : super(color, 2.0);

  @override
  void draw(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    const carWidth = 50.0;
    const carHeight = 26.0;

    // Car body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: carWidth, height: carHeight),
      const Radius.circular(4),
    );
    final bodyPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bodyRect, bodyPaint);

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(bodyRect, outlinePaint);

    // Windshield front
    final windshield = Path();
    windshield.moveTo(carWidth * 0.25, -carHeight * 0.38);
    windshield.lineTo(carWidth * 0.15, -carHeight * 0.15);
    windshield.lineTo(carWidth * 0.15, carHeight * 0.15);
    windshield.lineTo(carWidth * 0.25, carHeight * 0.38);
    canvas.drawPath(windshield, outlinePaint);

    // Windshield rear
    final rearWindow = Path();
    rearWindow.moveTo(-carWidth * 0.25, -carHeight * 0.38);
    rearWindow.lineTo(-carWidth * 0.15, -carHeight * 0.15);
    rearWindow.lineTo(-carWidth * 0.15, carHeight * 0.15);
    rearWindow.lineTo(-carWidth * 0.25, carHeight * 0.38);
    canvas.drawPath(rearWindow, outlinePaint);

    // Direction arrow (front)
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(carWidth * 0.3, 0),
        const Offset(carWidth * 0.45, 0), arrowPaint);
    canvas.drawLine(const Offset(carWidth * 0.40, -4),
        const Offset(carWidth * 0.45, 0), arrowPaint);
    canvas.drawLine(const Offset(carWidth * 0.40, 4),
        const Offset(carWidth * 0.45, 0), arrowPaint);

    // Label
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }
}

class SignStamp extends DrawingElement {
  Offset position;
  final String signType; // "STOP", "CEDER", "FEU", "SENS_INTERDIT"
  final double angle;
  SignStamp(this.position, this.signType, this.angle, Color color)
      : super(color, 2.0);

  @override
  void draw(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2.0;

    if (signType == "STOP") {
      paint.color = Colors.red;
      final path = Path();
      const radius = 20.0;
      for (int i = 0; i < 8; i++) {
        final angle = (i * pi / 4) - (pi / 8);
        final px = radius * cos(angle);
        final py = radius * sin(angle);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);

      final textPainter = TextPainter(
        text: const TextSpan(
            text: "STOP",
            style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    } else if (signType == "CEDER") {
      paint.color = Colors.red;
      final path = Path();
      path.moveTo(-20, -15);
      path.lineTo(20, -15);
      path.lineTo(0, 20);
      path.close();
      canvas.drawPath(path, paint);
      paint.color = Colors.white;
      final innerPath = Path();
      innerPath.moveTo(-13, -11);
      innerPath.lineTo(13, -11);
      innerPath.lineTo(0, 13);
      innerPath.close();
      canvas.drawPath(innerPath, paint);
    } else if (signType == "FEU") {
      paint.color = Colors.grey.shade800;
      final rect = RRect.fromRectAndRadius(
          const Rect.fromLTRB(-10, -25, 10, 25), const Radius.circular(4));
      canvas.drawRRect(rect, paint);
      canvas.drawCircle(const Offset(0, -15), 6, Paint()..color = Colors.red);
      canvas.drawCircle(const Offset(0, 0), 6, Paint()..color = Colors.orange);
      canvas.drawCircle(const Offset(0, 15), 6, Paint()..color = Colors.green);
    } else if (signType == "SENS_INTERDIT") {
      paint.color = Colors.red;
      canvas.drawCircle(Offset.zero, 20, paint);
      canvas.drawCircle(Offset.zero, 20, strokePaint);
      paint.color = Colors.white;
      canvas.drawRect(const Rect.fromLTRB(-12, -4, 12, 4), paint);
    }

    canvas.restore();
  }
}

class TextLabel extends DrawingElement {
  Offset position;
  final String text;
  TextLabel(this.position, this.text, Color color) : super(color, 1.0);

  @override
  void draw(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    // Background
    final bgRect = Rect.fromLTWH(
      position.dx - 3,
      position.dy - 2,
      tp.width + 6,
      tp.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(3)),
      Paint()..color = Colors.white.withOpacity(0.85),
    );

    tp.paint(canvas, position);
  }
}

// ══════════════════════════════════════════════════════════════════════
// CANVAS CONTROLLER
// ══════════════════════════════════════════════════════════════════════
class SmartCanvasController extends ChangeNotifier {
  final List<DrawingElement> elements = [];
  final List<DrawingElement> _undoStack = [];

  bool get isEmpty => elements.isEmpty;
  bool get canUndo => elements.isNotEmpty;
  bool get canRedo => _undoStack.isNotEmpty;

  void addElement(DrawingElement element) {
    elements.add(element);
    _undoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (elements.isNotEmpty) {
      _undoStack.add(elements.removeLast());
      notifyListeners();
    }
  }

  void redo() {
    if (_undoStack.isNotEmpty) {
      elements.add(_undoStack.removeLast());
      notifyListeners();
    }
  }

  void clear() {
    elements.clear();
    _undoStack.clear();
    notifyListeners();
  }

  void removeElementsAt(Offset point, double radius,
      double Function(Offset p, Offset a, Offset b) pointToSegmentDist) {
    bool changed = false;
    elements.removeWhere((e) {
      bool shouldRemove = false;
      if (e is PenStroke) {
        shouldRemove = e.points.any((p) => (p - point).distance < radius);
      } else if (e is CarStamp) {
        shouldRemove = (e.position - point).distance < radius * 2;
      } else if (e is TextLabel) {
        shouldRemove = (e.position - point).distance < radius * 1.5;
      } else if (e is LineDraw) {
        shouldRemove = pointToSegmentDist(point, e.start, e.end) < radius;
      } else if (e is ArrowDraw) {
        shouldRemove = pointToSegmentDist(point, e.start, e.end) < radius;
      } else if (e is RectDraw) {
        // Simple check for rectangle corners/edges
        shouldRemove = (e.rect.topLeft - point).distance < radius ||
            (e.rect.topRight - point).distance < radius ||
            (e.rect.bottomLeft - point).distance < radius ||
            (e.rect.bottomRight - point).distance < radius;
      }

      if (shouldRemove) {
        changed = true;
        return true;
      }
      return false;
    });

    if (changed) {
      _undoStack.clear();
      notifyListeners();
    }
  }

  Future<Uint8List?> toPngBytes(
      {double width = 1000, double height = 600}) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

      // White background
      canvas.drawRect(
          Rect.fromLTWH(0, 0, width, height), Paint()..color = Colors.white);

      // Grid
      _drawGrid(canvas, Size(width, height));

      for (var element in elements) {
        element.draw(canvas, Size(width, height));
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.5;
    const step = 25.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// SMART CANVAS WIDGET
// ══════════════════════════════════════════════════════════════════════
class SmartCanvasWidget extends StatefulWidget {
  final SmartCanvasController controller;
  final double? height;
  final bool isFullscreen;

  const SmartCanvasWidget({
    super.key,
    required this.controller,
    this.height = 350,
    this.isFullscreen = false,
  });

  @override
  State<SmartCanvasWidget> createState() => _SmartCanvasWidgetState();
}

class _SmartCanvasWidgetState extends State<SmartCanvasWidget> {
  DrawingTool _currentTool = DrawingTool.pen;
  Color _currentColor = Colors.black;
  final double _currentStrokeWidth = 2.5;

  List<Offset> _currentPoints = [];
  Offset? _dragStart;
  Offset? _dragEnd;
  final double _carAngle = 0.0;
  String _currentSignType = "STOP";

  // Point sampling to reduce noise
  static const double _minDistance = 3.0;
  static const double _snapThreshold = 25.0;

  Offset _snapToEndpoints(Offset point, {DrawingElement? exclude}) {
    Offset closestPoint = point;
    double minDistance = _snapThreshold;

    for (var element in widget.controller.elements) {
      if (element == exclude) continue;

      List<Offset> endpoints = [];
      if (element is PenStroke && element.points.isNotEmpty) {
        endpoints.add(element.points.first);
        endpoints.add(element.points.last);
      } else if (element is LineDraw) {
        endpoints.add(element.start);
        endpoints.add(element.end);
      } else if (element is ArrowDraw) {
        endpoints.add(element.start);
        endpoints.add(element.end);
      }

      for (var ep in endpoints) {
        double dist = (ep - point).distance;
        if (dist < minDistance) {
          minDistance = dist;
          closestPoint = ep;
        }
      }
    }
    return closestPoint;
  }

  // Dragging state
  DrawingElement? _draggedElement;
  Offset? _lastDragPos;

  void _onPanStart(DragStartDetails details) {
    if (_currentTool == DrawingTool.move) {
      _draggedElement = null;
      _lastDragPos = details.localPosition;
      // Find if we touched an element (search in reverse order for top-most)
      for (var i = widget.controller.elements.length - 1; i >= 0; i--) {
        final el = widget.controller.elements[i];
        if (el is CarStamp) {
          if ((el.position - details.localPosition).distance < 40) {
            _draggedElement = el;
            break;
          }
        } else if (el is LineDraw) {
          if (_pointToSegmentDist(details.localPosition, el.start, el.end) <
              20) {
            _draggedElement = el;
            break;
          }
        } else if (el is ArrowDraw) {
          if (_pointToSegmentDist(details.localPosition, el.start, el.end) <
              20) {
            _draggedElement = el;
            break;
          }
        } else if (el is PenStroke) {
          bool hit = false;
          for (var p in el.points) {
            if ((p - details.localPosition).distance < 20) {
              hit = true;
              break;
            }
          }
          if (hit) {
            _draggedElement = el;
            break;
          }
        } else if (el is CircleDraw) {
          if ((el.center - details.localPosition).distance < el.radius + 15 &&
              (el.center - details.localPosition).distance > el.radius - 15) {
            _draggedElement = el;
            break;
          }
        } else if (el is RectDraw) {
          if (el.rect.inflate(15).contains(details.localPosition)) {
            _draggedElement = el;
            break;
          }
        } else if (el is SignStamp) {
          if ((el.position - details.localPosition).distance < 25) {
            _draggedElement = el;
            break;
          }
        } else if (el is TextLabel) {
          if ((el.position - details.localPosition).distance < 30) {
            _draggedElement = el;
            break;
          }
        }
      }
    } else {
      Offset startPoint = _snapToEndpoints(details.localPosition);
      _dragStart = startPoint;
      if (_currentTool == DrawingTool.pen) {
        _currentPoints = [startPoint];
      }
    }
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentTool == DrawingTool.move &&
        _draggedElement != null &&
        _lastDragPos != null) {
      final delta = details.localPosition - _lastDragPos!;
      _lastDragPos = details.localPosition;

      final el = _draggedElement!;
      if (el is CarStamp) {
        el.position += delta;
      } else if (el is LineDraw) {
        el.start += delta;
        el.end += delta;
      } else if (el is ArrowDraw) {
        el.start += delta;
        el.end += delta;
      } else if (el is RectDraw) {
        el.rect = el.rect.shift(delta);
      } else if (el is CircleDraw) {
        el.center += delta;
      } else if (el is PenStroke) {
        for (int i = 0; i < el.points.length; i++) {
          el.points[i] += delta;
        }
      } else if (el is TextLabel) {
        el.position += delta;
      } else if (el is SignStamp) {
        el.position += delta;
      }

      // Notify listeners to trigger a repaint
      widget.controller.notifyListeners();
    } else if (_currentTool == DrawingTool.pen) {
      // Only add point if far enough from last point (reduces noise)
      if (_currentPoints.isNotEmpty) {
        final lastPoint = _currentPoints.last;
        final dist = (details.localPosition - lastPoint).distance;
        if (dist >= _minDistance) {
          _currentPoints.add(details.localPosition);
        }
      }
    } else if (_currentTool == DrawingTool.eraser) {
      // Erase elements near the touch point
      _eraseAt(details.localPosition);
    } else {
      Offset snapped = _snapToEndpoints(details.localPosition);
      if (snapped == details.localPosition &&
          _dragStart != null &&
          (_currentTool == DrawingTool.line ||
              _currentTool == DrawingTool.arrow)) {
        snapped = _snapLine(_dragStart!, details.localPosition);
      }
      _dragEnd = snapped;
    }
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentTool == DrawingTool.pen && _currentPoints.length >= 2) {
      _currentPoints.last = _snapToEndpoints(_currentPoints.last);
      widget.controller.addElement(PenStroke(
          List.from(_currentPoints), _currentColor, _currentStrokeWidth));
    } else if (_currentTool == DrawingTool.line &&
        _dragStart != null &&
        _dragEnd != null) {
      widget.controller.addElement(
          LineDraw(_dragStart!, _dragEnd!, _currentColor, _currentStrokeWidth));
    } else if (_currentTool == DrawingTool.arrow &&
        _dragStart != null &&
        _dragEnd != null) {
      widget.controller.addElement(ArrowDraw(
          _dragStart!, _dragEnd!, _currentColor, _currentStrokeWidth));
    } else if (_currentTool == DrawingTool.rectangle &&
        _dragStart != null &&
        _dragEnd != null) {
      widget.controller.addElement(RectDraw(
          Rect.fromPoints(_dragStart!, _dragEnd!),
          _currentColor,
          _currentStrokeWidth));
    } else if (_currentTool == DrawingTool.circle &&
        _dragStart != null &&
        _dragEnd != null) {
      double radius = (_dragEnd! - _dragStart!).distance;
      widget.controller.addElement(
          CircleDraw(_dragStart!, radius, _currentColor, _currentStrokeWidth));
    } else if (_currentTool == DrawingTool.carA && _dragStart != null) {
      double angle = 0.0;
      if (_dragEnd != null && _dragStart != _dragEnd) {
        angle =
            atan2(_dragEnd!.dy - _dragStart!.dy, _dragEnd!.dx - _dragStart!.dx);
      }
      widget.controller
          .addElement(CarStamp(_dragStart!, "A", angle, Colors.blue.shade700));
    } else if (_currentTool == DrawingTool.carB && _dragStart != null) {
      double angle = 0.0;
      if (_dragEnd != null && _dragStart != _dragEnd) {
        angle =
            atan2(_dragEnd!.dy - _dragStart!.dy, _dragEnd!.dx - _dragStart!.dx);
      }
      widget.controller
          .addElement(CarStamp(_dragStart!, "B", angle, Colors.red.shade700));
    } else if (_currentTool == DrawingTool.sign && _dragStart != null) {
      double angle = 0.0;
      if (_dragEnd != null && _dragStart != _dragEnd) {
        angle =
            atan2(_dragEnd!.dy - _dragStart!.dy, _dragEnd!.dx - _dragStart!.dx);
      }
      widget.controller.addElement(
          SignStamp(_dragStart!, _currentSignType, angle, Colors.transparent));
    }

    if (_currentTool == DrawingTool.move) {
      if (_draggedElement != null) {
        final el = _draggedElement!;
        if (el is LineDraw || el is ArrowDraw) {
          Offset startPt =
              (el is LineDraw) ? el.start : (el as ArrowDraw).start;
          Offset endPt = (el is LineDraw) ? el.end : (el as ArrowDraw).end;

          Offset? snappedDelta;
          Offset snappedStart = _snapToEndpoints(startPt, exclude: el);
          if (snappedStart != startPt) {
            snappedDelta = snappedStart - startPt;
          } else {
            Offset snappedEnd = _snapToEndpoints(endPt, exclude: el);
            if (snappedEnd != endPt) {
              snappedDelta = snappedEnd - endPt;
            }
          }

          if (snappedDelta != null) {
            if (el is LineDraw) {
              el.start += snappedDelta;
              el.end += snappedDelta;
            } else if (el is ArrowDraw) {
              el.start += snappedDelta;
              el.end += snappedDelta;
            }
          }
        }
      }

      _draggedElement = null;
      _lastDragPos = null;
      widget.controller.notifyListeners();
    }

    _currentPoints = [];
    _dragStart = null;
    _dragEnd = null;
    setState(() {});
  }

  Offset _snapLine(Offset start, Offset end) {
    if ((end.dx - start.dx).abs() < 15) return Offset(start.dx, end.dy);
    if ((end.dy - start.dy).abs() < 15) return Offset(end.dx, start.dy);
    return end;
  }

  void _eraseAt(Offset point) {
    widget.controller.removeElementsAt(point, 15.0, _pointToSegmentDist);
  }

  double _pointToSegmentDist(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final t = (ap.dx * ab.dx + ap.dy * ab.dy) / (ab.dx * ab.dx + ab.dy * ab.dy);
    final clamped = t.clamp(0.0, 1.0);
    final closest = Offset(a.dx + clamped * ab.dx, a.dy + clamped * ab.dy);
    return (p - closest).distance;
  }

  void _addTextLabel() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Ajouter du texte",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Ex: Avenue Victor Hugo",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                widget.controller.addElement(TextLabel(
                    const Offset(20, 20), controller.text, _currentColor));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryBlue),
            child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignSelectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Type de panneau",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: ["STOP", "CEDER", "FEU", "SENS_INTERDIT"].map((type) {
            final isSelected = _currentSignType == type;
            final label = {
              "STOP": "Stop",
              "CEDER": "Cédez-le-passage",
              "FEU": "Feu tricolore",
              "SENS_INTERDIT": "Sens interdit"
            }[type]!;
            return GestureDetector(
              onTap: () {
                setState(() => _currentSignType = type);
                Navigator.pop(ctx);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.secondaryBlue : AppColors.scaffold,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: AppColors.primaryBlue)
                      : null,
                ),
                child: Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.mediumGrey,
                    )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(),
          const SizedBox(height: 8),
          // Canvas
          Expanded(
            child: _buildCanvasArea(),
          ),
          const SizedBox(height: 8),
          // Bottom actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      height: widget.isFullscreen ? null : widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            size: Size.infinite,
            painter: _CanvasPainter(
              controller: widget.controller,
              currentPoints: _currentPoints,
              currentTool: _currentTool,
              color: _currentColor,
              strokeWidth: _currentStrokeWidth,
              dragStart: _dragStart,
              dragEnd: _dragEnd,
              currentSignType: _currentSignType,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _toolBtn(DrawingTool.pen, Icons.edit_rounded, "Stylo"),
            _toolBtn(DrawingTool.line, Icons.horizontal_rule_rounded, "Ligne"),
            _toolBtn(DrawingTool.arrow, Icons.arrow_forward_rounded, "Flèche"),
            _toolBtn(DrawingTool.rectangle, Icons.crop_square_rounded, "Rect"),
            _toolBtn(DrawingTool.circle, Icons.radio_button_unchecked_rounded,
                "Cercle"),
            _divider(),
            _toolBtn(DrawingTool.move, Icons.pan_tool_rounded, "Déplacer"),
            _divider(),
            _toolBtn(DrawingTool.carA, Icons.directions_car, "Auto A",
                Colors.blue.shade700),
            _toolBtn(DrawingTool.carB, Icons.directions_car, "Auto B",
                Colors.red.shade700),
            _toolBtn(DrawingTool.sign, Icons.traffic_rounded, "Panneau"),
            _divider(),
            _toolBtn(DrawingTool.text, Icons.text_fields_rounded, "Texte"),
            _toolBtn(DrawingTool.eraser, Icons.auto_fix_high_rounded, "Gomme"),
            if (!widget.isFullscreen) ...[
              _divider(),
              _expandBtn(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _expandBtn() {
    return GestureDetector(
      onTap: () {
        // Navigation will be handled here
        Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) =>
                FullscreenCanvasScreen(controller: widget.controller),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.secondaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          children: [
            Icon(Icons.fullscreen_rounded,
                size: 18, color: AppColors.secondaryBlue),
            Text("Plein écran",
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: AppColors.lightGrey,
      );

  Widget _toolBtn(DrawingTool tool, IconData icon, String label,
      [Color? overrideColor]) {
    final isSelected = _currentTool == tool;
    final color = overrideColor ?? AppColors.secondaryBlue;
    return GestureDetector(
      onTap: () {
        setState(() => _currentTool = tool);
        if (tool == DrawingTool.text) _addTextLabel();
        if (tool == DrawingTool.sign) _showSignSelectionDialog();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18, color: isSelected ? color : AppColors.mediumGrey),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : AppColors.mediumGrey,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        // Color pickers
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ([
                Colors.black,
                Colors.blue.shade700,
                Colors.red.shade700,
                Colors.green.shade700,
                Colors.grey
              ]).map((c) {
                return GestureDetector(
                  onTap: () => setState(() => _currentColor = c),
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentColor == c
                            ? AppColors.secondaryBlue
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Undo/Redo
        IconButton(
          onPressed: widget.controller.canUndo
              ? () {
                  widget.controller.undo();
                  setState(() {});
                }
              : null,
          icon: const Icon(Icons.undo_rounded, size: 20),
          tooltip: "Annuler",
        ),
        IconButton(
          onPressed: widget.controller.canRedo
              ? () {
                  widget.controller.redo();
                  setState(() {});
                }
              : null,
          icon: const Icon(Icons.redo_rounded, size: 20),
          tooltip: "Rétablir",
        ),
        IconButton(
          onPressed: () {
            widget.controller.clear();
            setState(() {});
          },
          icon: const Icon(Icons.delete_outline_rounded,
              size: 20, color: AppColors.redDanger),
          tooltip: "Tout effacer",
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// CANVAS PAINTER
// ══════════════════════════════════════════════════════════════════════
class _CanvasPainter extends CustomPainter {
  final SmartCanvasController controller;
  final List<Offset> currentPoints;
  final DrawingTool currentTool;
  final Color color;
  final double strokeWidth;
  final Offset? dragStart;
  final Offset? dragEnd;
  final String currentSignType;

  _CanvasPainter({
    required this.controller,
    required this.currentPoints,
    required this.currentTool,
    required this.color,
    required this.strokeWidth,
    this.dragStart,
    this.dragEnd,
    required this.currentSignType,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    // Grid background
    _drawGrid(canvas, size);

    // Draw all elements
    for (var element in controller.elements) {
      element.draw(canvas, size);
    }

    // Draw current stroke preview
    if (currentTool == DrawingTool.pen && currentPoints.length >= 2) {
      final previewPaint = Paint()
        ..color = color.withOpacity(0.5)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(currentPoints[0].dx, currentPoints[0].dy);
      for (int i = 1; i < currentPoints.length - 1; i++) {
        final p0 = currentPoints[i];
        final p1 = currentPoints[i + 1];
        path.quadraticBezierTo(
            p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      }
      path.lineTo(currentPoints.last.dx, currentPoints.last.dy);
      canvas.drawPath(path, previewPaint);
    }

    // Line/Arrow/Rect preview
    if (dragStart != null && dragEnd != null) {
      final previewPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (currentTool == DrawingTool.line) {
        canvas.drawLine(dragStart!, dragEnd!, previewPaint);
      } else if (currentTool == DrawingTool.arrow) {
        canvas.drawLine(dragStart!, dragEnd!, previewPaint);
        // Arrow preview
        final angle =
            atan2(dragEnd!.dy - dragStart!.dy, dragEnd!.dx - dragStart!.dx);
        final tp = Path();
        tp.moveTo(dragEnd!.dx, dragEnd!.dy);
        tp.lineTo(dragEnd!.dx - 12 * cos(angle - 0.5),
            dragEnd!.dy - 12 * sin(angle - 0.5));
        tp.moveTo(dragEnd!.dx, dragEnd!.dy);
        tp.lineTo(dragEnd!.dx - 12 * cos(angle + 0.5),
            dragEnd!.dy - 12 * sin(angle + 0.5));
        canvas.drawPath(tp, previewPaint);
      } else if (currentTool == DrawingTool.rectangle) {
        canvas.drawRect(Rect.fromPoints(dragStart!, dragEnd!), previewPaint);
      } else if (currentTool == DrawingTool.circle) {
        double radius = (dragEnd! - dragStart!).distance;
        canvas.drawCircle(dragStart!, radius, previewPaint);
      } else if (currentTool == DrawingTool.sign) {
        double angle = 0.0;
        if (dragStart != dragEnd) {
          angle =
              atan2(dragEnd!.dy - dragStart!.dy, dragEnd!.dx - dragStart!.dx);
        }
        SignStamp(dragStart!, currentSignType, angle, Colors.transparent)
            .draw(canvas, size);
      } else if (currentTool == DrawingTool.carA ||
          currentTool == DrawingTool.carB) {
        double angle = 0.0;
        if (dragStart != dragEnd) {
          angle =
              atan2(dragEnd!.dy - dragStart!.dy, dragEnd!.dx - dragStart!.dx);
        }
        String label = currentTool == DrawingTool.carA ? "A" : "B";
        Color carColor = currentTool == DrawingTool.carA
            ? Colors.blue.shade700
            : Colors.red.shade700;
        CarStamp(dragStart!, label, angle, carColor).draw(canvas, size);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..strokeWidth = 0.5;
    const step = 25.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
