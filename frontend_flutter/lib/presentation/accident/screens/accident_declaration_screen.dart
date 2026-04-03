import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class AccidentDeclarationScreen extends StatefulWidget {
  const AccidentDeclarationScreen({super.key});

  @override
  State<AccidentDeclarationScreen> createState() =>
      _AccidentDeclarationScreenState();
}

class _AccidentDeclarationScreenState
    extends State<AccidentDeclarationScreen> {

  XFile? image;
  Position? position;

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    image = await picker.pickImage(source: ImageSource.camera);
    setState(() {});
  }

  Future<void> getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Déclaration Accident")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: takePhoto,
              child: const Text("Prendre Photo"),
            ),
            ElevatedButton(
              onPressed: getLocation,
              child: const Text("Obtenir Localisation"),
            ),
            if (position != null)
              Text("Latitude: ${position!.latitude}"),
          ],
        ),
      ),
    );
  }
}