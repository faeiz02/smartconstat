import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../accident/screens/accident_declaration_screen.dart';
import '../../data/models/user_model.dart';
import '../accident/screens/accident_declaration_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Utilisateur"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Retour à l'écran de vérification
              Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/id-verification',
                      (route) => false
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Photo de profil (placeholder)
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Carte Informations Personnelles
            _buildInfoCard(
              title: "Informations Personnelles",
              icon: Icons.person,
              children: [
                _buildInfoRow("Nom complet", "${user.nom} ${user.prenom}"),
                _buildInfoRow("CIN", user.cin),
                _buildInfoRow("Téléphone", user.phone),
                _buildInfoRow("Email", user.email),
              ],
            ),

            const SizedBox(height: 15),

            // ✅ Carte Informations Véhicule
            _buildInfoCard(
              title: "Informations Véhicule",
              icon: Icons.directions_car,
              children: [
                _buildInfoRow("Marque", "${user.vehicleBrand} ${user.vehicleModel}"),
                _buildInfoRow("Matricule", user.vehiclePlate),
                _buildInfoRow("N° Assurance", user.insuranceNumber),
              ],
            ),

            const SizedBox(height: 25),

            // ✅ Bouton Déclarer Accident
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.car_crash, size: 24),
                label: const Text(
                  "Déclarer un Accident",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccidentDeclarationScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les cartes d'information
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget pour chaque ligne d'information
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}