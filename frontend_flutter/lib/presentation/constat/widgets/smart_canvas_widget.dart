import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../screens/fullscreen_canvas_screen.dart';

// ══════════════════════════════════════════════════════════════════════
// DRAWING TOOL TYPES
// ══════════════════════════════════════════════════════════════════════
enum DrawingTool { pen, line, rectangle, arrow, carA, carB, text, eraser }

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
  final Offset start;
  final Offset end;
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
  final Offset start;
  final Offset end;
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
    path.lineTo(
        end.dx - arrowSize * cos(angle - 0.5),
        end.dy - arrowSize * sin(angle - 0.5));
    path.moveTo(end.dx, end.dy);
    path.lineTo(
        end.dx - arrowSize * cos(angle + 0.5),
        end.dy - arrowSize * sin(angle + 0.5));
    canvas.drawPath(path, paint..strokeWidth = strokeWidth + 1);
  }
}

class RectDraw extends DrawingElement {
  final Rect rect;
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

class CarStamp extends DrawingElement {
  final Offset position;
  final String label; // "A" or "B"
  final double angle;
  CarStamp(this.position, this.label, this.angle, Color color)
      : super(color, 2.0);

  @override
  void draw(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    final carWidth = 50.0;
    final carHeight = 26.0;

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
    canvas.drawLine(Offset(carWidth * 0.3, 0), Offset(carWidth * 0.45, 0), arrowPaint);
    canvas.drawLine(Offset(carWidth * 0.40, -4), Offset(carWidth * 0.45, 0), arrowPaint);
    canvas.drawLine(Offset(carWidth * 0.40, 4), Offset(carWidth * 0.45, 0), arrowPaint);

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

class TextLabel extends DrawingElement {
  final Offset position;
  final String text;
  TextLabel(this.position, this.text, Color color)
      : super(color, 1.0);

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

  void removeElementsAt(Offset point, double radius, double Function(Offset p, Offset a, Offset b) pointToSegmentDist) {
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

  Future<Uint8List?> toPngBytes({double width = 1000, double height = 600}) async {
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
  double _currentStrokeWidth = 2.5;
  
  List<Offset> _currentPoints = [];
  Offset? _dragStart;
  Offset? _dragEnd;
  double _carAngle = 0.0;

  // Point sampling to reduce noise
  static const double _minDistance = 3.0;

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
    if (_currentTool == DrawingTool.pen) {
      _currentPoints = [details.localPosition];
    }
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentTool == DrawingTool.pen) {
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
      _dragEnd = details.localPosition;
    }
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentTool == DrawingTool.pen && _currentPoints.length >= 2) {
      widget.controller.addElement(
          PenStroke(List.from(_currentPoints), _currentColor, _currentStrokeWidth));
    } else if (_currentTool == DrawingTool.line && _dragStart != null && _dragEnd != null) {
      // Snap to horizontal/vertical if close
      Offset sEnd = _snapLine(_dragStart!, _dragEnd!);
      widget.controller.addElement(
          LineDraw(_dragStart!, sEnd, _currentColor, _currentStrokeWidth));
    } else if (_currentTool == DrawingTool.arrow && _dragStart != null && _dragEnd != null) {
      Offset sEnd = _snapLine(_dragStart!, _dragEnd!);
      widget.controller.addElement(
          ArrowDraw(_dragStart!, sEnd, _currentColor, _currentStrokeWidth));
    } else if (_currentTool == DrawingTool.rectangle && _dragStart != null && _dragEnd != null) {
      widget.controller.addElement(RectDraw(
          Rect.fromPoints(_dragStart!, _dragEnd!), _currentColor, _currentStrokeWidth));
    } else if (_currentTool == DrawingTool.carA && _dragStart != null) {
      widget.controller.addElement(
          CarStamp(_dragEnd ?? _dragStart!, "A", _carAngle, Colors.blue.shade700));
    } else if (_currentTool == DrawingTool.carB && _dragStart != null) {
      widget.controller.addElement(
          CarStamp(_dragEnd ?? _dragStart!, "B", _carAngle, Colors.red.shade700));
    }

    _currentPoints = [];
    _dragStart = null;
    _dragEnd = null;
    setState(() {});
  }

  Offset _snapLine(Offset start, Offset end) {
    if ((end.dx - start.dx).abs() < 12) return Offset(start.dx, end.dy);
    if ((end.dy - start.dy).abs() < 12) return Offset(end.dx, start.dy);
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
        title: const Text("Ajouter du texte", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Ex: Avenue Victor Hugo",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                widget.controller.addElement(
                    TextLabel(const Offset(20, 20), controller.text, _currentColor));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryBlue),
            child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRotationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Rotation du véhicule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: _carAngle,
                child: Icon(Icons.directions_car, size: 60, color: _currentTool == DrawingTool.carA ? Colors.blue : Colors.red),
              ),
              const SizedBox(height: 16),
              Slider(
                value: _carAngle,
                min: -pi,
                max: pi,
                divisions: 12,
                label: "${(_carAngle * 180 / pi).round()}°",
                onChanged: (v) {
                  setDialogState(() => _carAngle = v);
                  setState(() {});
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0.0, pi / 4, pi / 2, pi, -pi / 2].map((a) {
                  final label = {0.0: "0°", pi/4: "45°", pi/2: "90°", pi: "180°", -pi/2: "-90°"}[a]!;
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() => _carAngle = a);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _carAngle == a ? AppColors.secondaryBlue : AppColors.scaffold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(label, style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _carAngle == a ? Colors.white : AppColors.mediumGrey,
                      )),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryBlue),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
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
          if (widget.isFullscreen)
            Expanded(
              child: _buildCanvasArea(),
            )
          else
            _buildCanvasArea(),
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
            _divider(),
            _toolBtn(DrawingTool.carA, Icons.directions_car, "Auto A", Colors.blue.shade700),
            _toolBtn(DrawingTool.carB, Icons.directions_car, "Auto B", Colors.red.shade700),
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
            builder: (context) => FullscreenCanvasScreen(controller: widget.controller),
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
            Icon(Icons.fullscreen_rounded, size: 18, color: AppColors.secondaryBlue),
            Text("Plein écran", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1, height: 30,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    color: AppColors.lightGrey,
  );

  Widget _toolBtn(DrawingTool tool, IconData icon, String label, [Color? overrideColor]) {
    final isSelected = _currentTool == tool;
    final color = overrideColor ?? AppColors.secondaryBlue;
    return GestureDetector(
      onTap: () {
        setState(() => _currentTool = tool);
        if (tool == DrawingTool.text) _addTextLabel();
        if ((tool == DrawingTool.carA || tool == DrawingTool.carB)) _showRotationDialog();
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
            Icon(icon, size: 18, color: isSelected ? color : AppColors.mediumGrey),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
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
        ...([Colors.black, Colors.blue.shade700, Colors.red.shade700, Colors.green.shade700, Colors.grey]).map((c) {
          return GestureDetector(
            onTap: () => setState(() => _currentColor = c),
            child: Container(
              width: 24, height: 24,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _currentColor == c ? AppColors.secondaryBlue : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        // Undo/Redo
        IconButton(
          onPressed: widget.controller.canUndo ? () {
            widget.controller.undo();
            setState(() {});
          } : null,
          icon: const Icon(Icons.undo_rounded, size: 20),
          tooltip: "Annuler",
        ),
        IconButton(
          onPressed: widget.controller.canRedo ? () {
            widget.controller.redo();
            setState(() {});
          } : null,
          icon: const Icon(Icons.redo_rounded, size: 20),
          tooltip: "Rétablir",
        ),
        IconButton(
          onPressed: () {
            widget.controller.clear();
            setState(() {});
          },
          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.redDanger),
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

  _CanvasPainter({
    required this.controller,
    required this.currentPoints,
    required this.currentTool,
    required this.color,
    required this.strokeWidth,
    this.dragStart,
    this.dragEnd,
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
        path.quadraticBezierTo(p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
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
        final angle = atan2(dragEnd!.dy - dragStart!.dy, dragEnd!.dx - dragStart!.dx);
        final tp = Path();
        tp.moveTo(dragEnd!.dx, dragEnd!.dy);
        tp.lineTo(dragEnd!.dx - 12 * cos(angle - 0.5), dragEnd!.dy - 12 * sin(angle - 0.5));
        tp.moveTo(dragEnd!.dx, dragEnd!.dy);
        tp.lineTo(dragEnd!.dx - 12 * cos(angle + 0.5), dragEnd!.dy - 12 * sin(angle + 0.5));
        canvas.drawPath(tp, previewPaint);
      } else if (currentTool == DrawingTool.rectangle) {
        canvas.drawRect(Rect.fromPoints(dragStart!, dragEnd!), previewPaint);
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
