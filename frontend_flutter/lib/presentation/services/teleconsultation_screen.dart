import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TeleconsultationScreen extends StatelessWidget {
  const TeleconsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Téléconsultation"),
        backgroundColor: AppColors.greenSuccess,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildDoctorsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.greenSuccess.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Consultation à distance", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Consultez un médecin en visioconférence", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.video_call_outlined, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    final doctors = [
      {"name": "Dr. Ahmed Ben Mahmoud", "specialty": "Médecin généraliste", "available": true, "rating": 4.8},
      {"name": "Dr. Salma Toumi", "specialty": "Dermatologue", "available": true, "rating": 4.9},
      {"name": "Dr. Karim Jaziri", "specialty": "Pédiatre", "available": false, "rating": 4.7},
      {"name": "Dr. Ines Khemiri", "specialty": "Cardiologue", "available": true, "rating": 4.8},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Médecins disponibles", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...doctors.map((d) => _buildDoctorCard(d)),
      ],
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final available = doctor["available"] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.greenSuccess.withOpacity(0.15), AppColors.greenSuccess.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.greenSuccess, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor["name"] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(doctor["specialty"] as String, style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 3),
                  Text("${doctor["rating"]}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ),
          if (available)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenSuccess,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                minimumSize: Size.zero,
              ),
              child: const Text("Consulter", style: TextStyle(fontSize: 12)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(20)),
              child: const Text("Indisponible", style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}