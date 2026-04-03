import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AssistanceVoyageScreen extends StatelessWidget {
  const AssistanceVoyageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Assistance Voyage"),
        backgroundColor: AppColors.orangeWarning,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildVoyageActif(),
            const SizedBox(height: 16),
            _buildGarantiesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.orangeWarning, Color(0xFFFBBF24)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.orangeWarning.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Protection à l'étranger", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Assistance complète lors de vos déplacements", style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildVoyageActif() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.orangeWarning.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.orangeWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.flight_rounded, color: AppColors.orangeWarning),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Paris, France", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text("15/06/2025 – 15/07/2025", style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.greenSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: const Text("Actif", style: TextStyle(color: AppColors.greenSuccess, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildGarantiesCard() {
    final garanties = [
      {"icon": Icons.medical_services_outlined, "title": "Frais médicaux", "desc": "Jusqu'à 50 000 €"},
      {"icon": Icons.flight_outlined, "title": "Rapatriement", "desc": "Prise en charge totale"},
      {"icon": Icons.luggage_outlined, "title": "Bagages", "desc": "Perte/vol jusqu'à 1 500 €"},
      {"icon": Icons.gavel_outlined, "title": "Assistance juridique", "desc": "Avocat sur place"},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Garanties incluses", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...garanties.map((g) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.orangeWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(g["icon"] as IconData, color: AppColors.orangeWarning, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g["title"] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(g["desc"] as String, style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}