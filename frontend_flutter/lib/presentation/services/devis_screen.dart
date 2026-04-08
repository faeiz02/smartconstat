import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/api_service_features.dart';

class DevisScreen extends StatefulWidget {
  const DevisScreen({super.key});

  @override
  State<DevisScreen> createState() => _DevisScreenState();
}

class _DevisScreenState extends State<DevisScreen> {
  String? _selected;
  bool _isLoading = false;

  void _submitDevis() async {
    if (_selected == null) return;
    
    setState(() => _isLoading = true);
    final success = await ApiServiceFeatures.requestDevis(_selected!);
    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Votre demande de devis a été envoyée !"), backgroundColor: AppColors.greenSuccess),
      );
      // Wait a bit and pop
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'envoi de la demande."), backgroundColor: AppColors.redDanger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Devis en ligne"),
        backgroundColor: AppColors.pinkDevis,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildDevisForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.pinkDevis, Color(0xFFF472B6)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.pinkDevis.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Devis personnalisé", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Obtenez un devis gratuit en 2 minutes", style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.request_quote_outlined, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildDevisForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Choisissez votre assurance", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _buildDevisOption(icon: Icons.directions_car_outlined, title: "Assurance Auto", price: "à partir de 450 DT/an", color: AppColors.secondaryBlue),
          const SizedBox(height: 10),
          _buildDevisOption(icon: Icons.home_outlined, title: "Assurance Habitation", price: "à partir de 300 DT/an", color: AppColors.purpleAssistance),
          const SizedBox(height: 10),
          _buildDevisOption(icon: Icons.favorite_outline, title: "Assurance Santé", price: "à partir de 600 DT/an", color: AppColors.redDanger),
          const SizedBox(height: 10),
          _buildDevisOption(icon: Icons.flight_takeoff_rounded, title: "Assurance Voyage", price: "à partir de 80 DT/séjour", color: AppColors.orangeWarning),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (_selected != null && !_isLoading) ? _submitDevis : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkDevis,
                disabledBackgroundColor: AppColors.lightGrey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Obtenir un devis", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevisOption({required IconData icon, required String title, required String price, required Color color}) {
    final isSelected = _selected == title;
    return GestureDetector(
      onTap: () => setState(() => _selected = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.06) : Colors.white,
          border: Border.all(color: isSelected ? color : AppColors.lightGrey, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(price, style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? color : AppColors.lightGrey, width: 2),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}