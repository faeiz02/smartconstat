import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class Assistance247Screen extends StatelessWidget {
  const Assistance247Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Assistance 24/7"),
        backgroundColor: AppColors.purpleAssistance,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildEmergencyNumbers(),
            const SizedBox(height: 20),
            _buildAssistanceTypes(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.purpleAssistance, const Color(0xFFA78BFA)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.purpleAssistance.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Assistance permanente", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Équipe disponible 24h/24, 7j/7", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyNumbers() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Numéros d'urgence", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _buildNumberItem("Assistance dépannage", "31 31", Icons.car_repair_outlined),
          _buildNumberItem("Assistance médicale", "19 19", Icons.medical_services_outlined),
          _buildNumberItem("Assistance domicile", "31 32", Icons.home_repair_service_outlined),
        ],
      ),
    );
  }

  Widget _buildNumberItem(String label, String number, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.purpleAssistance.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.purpleAssistance, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.purpleAssistance)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purpleAssistance,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: Size.zero,
            ),
            child: const Text("Appeler", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistanceTypes() {
    final types = [
      {"icon": Icons.car_repair_outlined, "title": "Dépannage", "desc": "Véhicule en panne"},
      {"icon": Icons.medical_services_outlined, "title": "Médicale", "desc": "Urgence santé"},
      {"icon": Icons.home_repair_service_outlined, "title": "Domicile", "desc": "Plombier, électricien"},
      {"icon": Icons.gavel_outlined, "title": "Juridique", "desc": "Conseil juridique"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.15),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final t = types[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.purpleAssistance.withOpacity(0.12), AppColors.purpleAssistance.withOpacity(0.04)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(t["icon"] as IconData, color: AppColors.purpleAssistance, size: 28),
              ),
              const SizedBox(height: 10),
              Text(t["title"] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(t["desc"] as String, style: TextStyle(color: AppColors.mediumGrey, fontSize: 11), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}