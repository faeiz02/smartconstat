import 'package:flutter/material.dart';

class AiResultScreen extends StatelessWidget {
  final String responsable;
  final int pourcentage;

  const AiResultScreen({
    super.key,
    required this.responsable,
    required this.pourcentage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Résultat Analyse IA")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Responsable : $responsable",
                style: const TextStyle(fontSize: 20)),
            Text("Responsabilité : $pourcentage %",
                style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}