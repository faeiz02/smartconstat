import 'package:flutter/material.dart';
import '../widgets/smart_canvas_widget.dart';
import '../../../core/constants/app_colors.dart';

class FullscreenCanvasScreen extends StatefulWidget {
  final SmartCanvasController controller;

  const FullscreenCanvasScreen({super.key, required this.controller});

  @override
  State<FullscreenCanvasScreen> createState() => _FullscreenCanvasScreenState();
}

class _FullscreenCanvasScreenState extends State<FullscreenCanvasScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Croquis - Plein Écran", style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: const Text("TERMINER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SmartCanvasWidget(
            controller: widget.controller,
            isFullscreen: true,
          ),
        ),
      ),
    );
  }
}
