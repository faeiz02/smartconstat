import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ReseauSoinsScreen extends StatelessWidget {
  const ReseauSoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Réseau de soins"),
        backgroundColor: AppColors.tealSoins,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildCategoriesList(),
            const SizedBox(height: 20),
            _buildProfessionnelsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.tealSoins, Color(0xFF2DD4BF)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.tealSoins.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Professionnels de santé", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Trouvez un médecin ou une clinique", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.local_hospital_outlined, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Rechercher un professionnel...",
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.tealSoins),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true, fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    final categories = [
      {"icon": Icons.medical_services_outlined, "name": "Généraliste", "count": 45},
      {"icon": Icons.health_and_safety_outlined, "name": "Dentiste", "count": 23},
      {"icon": Icons.psychology_outlined, "name": "Psychologue", "count": 12},
      {"icon": Icons.monitor_heart_outlined, "name": "Cardiologue", "count": 8},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Catégories", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final c = categories[i];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(c["icon"] as IconData, color: AppColors.tealSoins, size: 24),
                    const SizedBox(height: 6),
                    Text(c["name"] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    Text("${c["count"]}", style: TextStyle(fontSize: 10, color: AppColors.mediumGrey)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionnelsList() {
    final pros = [
      {"name": "Clinique Les Jasmins", "type": "Clinique", "distance": "1.2 km", "address": "Tunis"},
      {"name": "Dr. Mohamed Salah", "type": "Généraliste", "distance": "2.5 km", "address": "Mutuelle Ville"},
      {"name": "Polyclinique CNSS", "type": "Clinique", "distance": "3.0 km", "address": "Montplaisir"},
      {"name": "Dr. Leila Mansour", "type": "Dentiste", "distance": "1.8 km", "address": "Lafayette"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("À proximité", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...pros.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.tealSoins.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  (p["type"] == "Clinique") ? Icons.local_hospital_outlined : Icons.person_outline,
                  color: AppColors.tealSoins, size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p["name"]!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(p["type"]!, style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
                    Text("${p["address"]} • ${p["distance"]}", style: TextStyle(color: AppColors.mediumGrey.withOpacity(0.7), fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.tealSoins.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.phone_outlined, color: AppColors.tealSoins, size: 18),
              ),
            ],
          ),
        )),
      ],
    );
  }
}