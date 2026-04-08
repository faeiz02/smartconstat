import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/api_service_features.dart';

class FacturesScreen extends StatefulWidget {
  const FacturesScreen({super.key});

  @override
  State<FacturesScreen> createState() => _FacturesScreenState();
}

class _FacturesScreenState extends State<FacturesScreen> {
  late Future<List<dynamic>> _facturesFuture;

  @override
  void initState() {
    super.initState();
    _facturesFuture = ApiServiceFeatures.getFactures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Mes factures"),
        backgroundColor: AppColors.brownFactures,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _facturesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.brownFactures));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement"));
          }

          final factures = snapshot.data ?? [];
          // Calculer les stats
          double totalPaye = 0;
          double aPayer = 0;
          for (var f in factures) {
             if (f['statut'] == 'Payée') {
               totalPaye += (f['montant'] as num).toDouble();
             } else {
               aPayer += (f['montant'] as num).toDouble();
             }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildStatsCards(totalPaye, aPayer),
                const SizedBox(height: 16),
                _buildFacturesList(factures),
              ],
            ),
          );
        }
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

  Widget _buildStatsCards(double totalPaye, double aPayer) {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Total payé", "${totalPaye.toStringAsFixed(0)} DT", Icons.check_circle_outline, AppColors.greenSuccess)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("À payer", "${aPayer.toStringAsFixed(0)} DT", Icons.hourglass_top_rounded, AppColors.orangeWarning)),
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

  Widget _buildFacturesList(List<dynamic> factures) {
    if (factures.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text("Aucune facture trouvée."),
      );
    }

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
                  Text("Échéance: ${f["echeance"]}", style: TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${f["montant"]} DT", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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