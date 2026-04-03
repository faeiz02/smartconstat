import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FacturesScreen extends StatelessWidget {
  const FacturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Mes factures"),
        backgroundColor: AppColors.brownFactures,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildStatsCards(),
            const SizedBox(height: 16),
            _buildFacturesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.brownFactures, Color(0xFFB45309)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.brownFactures.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Historique des paiements", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Consultez et téléchargez vos factures", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Total payé", "2 550 DT", Icons.check_circle_outline, AppColors.greenSuccess)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("À payer", "850 DT", Icons.hourglass_top_rounded, AppColors.orangeWarning)),
      ],
    );
  }

  Widget _buildStatCard(String label, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFacturesList() {
    final factures = [
      {"mois": "Mars 2026", "montant": "850 DT", "date": "05/03/2026", "statut": "À payer"},
      {"mois": "Février 2026", "montant": "850 DT", "date": "05/02/2026", "statut": "Payée"},
      {"mois": "Janvier 2026", "montant": "850 DT", "date": "05/01/2026", "statut": "Payée"},
      {"mois": "Décembre 2025", "montant": "850 DT", "date": "05/12/2025", "statut": "Payée"},
    ];

    return Column(children: factures.map((f) {
      final isPaid = f["statut"] == "Payée";
      final color = isPaid ? AppColors.greenSuccess : AppColors.orangeWarning;
      return Container(
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
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(isPaid ? Icons.check_circle_outline : Icons.hourglass_top_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f["mois"]!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text("Échéance: ${f["date"]}", style: TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(f["montant"]!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(f["statut"]!, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (!isPaid) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.brownFactures.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.payment_outlined, color: AppColors.brownFactures, size: 18),
              ),
            ],
          ],
        ),
      );
    }).toList());
  }
}