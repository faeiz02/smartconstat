import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddInsuranceScreen extends StatelessWidget {
  const AddInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Ajouter une assurance"),
        backgroundColor: AppColors.greenSuccess,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildInsuranceList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.greenSuccess.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Nouvelle assurance", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Protégez ce qui compte pour vous", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceList(BuildContext context) {
    final List<Map<String, dynamic>> assurances = [
      {"icon": Icons.home_outlined, "title": "Assurance Habitation", "color": AppColors.purpleAssistance, "desc": "Protégez votre logement", "prix": "300 DT/an", "garanties": ["Incendie", "Dégât des eaux", "Vol", "Responsabilité civile"], "formType": "habitation"},
      {"icon": Icons.favorite_outline, "title": "Assurance Santé", "color": AppColors.redDanger, "desc": "Couverture médicale complète", "prix": "600 DT/an", "garanties": ["Consultations", "Hospitalisation", "Médicaments", "Dentaire"], "formType": "sante"},
      {"icon": Icons.flight_takeoff_rounded, "title": "Assurance Voyage", "color": AppColors.orangeWarning, "desc": "Voyagez en toute sérénité", "prix": "80 DT/séjour", "garanties": ["Annulation", "Bagages", "Rapatriement", "Frais médicaux"], "formType": "voyage"},
      {"icon": Icons.pets_outlined, "title": "Assurance Animaux", "color": const Color(0xFF78350F), "desc": "Pour vos compagnons", "prix": "250 DT/an", "garanties": ["Soins vétérinaires", "Chirurgie", "Médicaments", "Responsabilité civile"], "formType": "animaux"},
      {"icon": Icons.school_outlined, "title": "Assurance Scolaire", "color": AppColors.tealSoins, "desc": "Protection pour vos enfants", "prix": "150 DT/an", "garanties": ["Accident scolaire", "Responsabilité civile", "Assistance", "Frais médicaux"], "formType": "scolaire"},
      {"icon": Icons.work_outline, "title": "Assurance Professionnelle", "color": AppColors.secondaryBlue, "desc": "Pour votre activité", "prix": "800 DT/an", "garanties": ["Responsabilité civile pro", "Locaux", "Matériel", "Perte d'exploitation"], "formType": "pro"},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: assurances.length,
      itemBuilder: (context, index) {
        final a = assurances[index];
        final Color color = a["color"];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _InsuranceDetailScreen(assurance: a))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(a["icon"], color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a["title"], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(a["desc"], style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                        child: Text(a["prix"], style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.scaffold, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.mediumGrey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── SHARED DETAIL SCREEN ───
class _InsuranceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> assurance;
  const _InsuranceDetailScreen({required this.assurance});

  @override
  Widget build(BuildContext context) {
    final Color color = assurance["color"];
    final String formType = assurance["formType"] ?? "";

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(assurance["title"]),
        backgroundColor: color,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(color),
            const SizedBox(height: 14),
            _buildPriceCard(color),
            const SizedBox(height: 14),
            _buildGarantiesCard(color),
            const SizedBox(height: 14),
            _buildForm(formType),
            const SizedBox(height: 20),
            _buildSubscribeButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(assurance["icon"], color: Colors.white, size: 36),
          ),
          const SizedBox(height: 14),
          Text(assurance["title"], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(assurance["desc"], style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPriceCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("À partir de ", style: TextStyle(fontSize: 15, color: AppColors.mediumGrey)),
          Text(assurance["prix"], style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildGarantiesCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Garanties incluses", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...(assurance["garanties"] as List<String>).map((g) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.check_rounded, color: color, size: 16),
                ),
                const SizedBox(width: 12),
                Text(g, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildForm(String formType) {
    final formFields = _getFormFields(formType);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formFields["title"]!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...(formFields["fields"]! as String).split("|").map((fieldLabel) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              decoration: InputDecoration(labelText: fieldLabel.trim()),
              keyboardType: fieldLabel.contains("Surface") || fieldLabel.contains("Âge") || fieldLabel.contains("Nombre") || fieldLabel.contains("Chiffre")
                  ? TextInputType.number : TextInputType.text,
            ),
          )),
        ],
      ),
    );
  }

  Map<String, dynamic> _getFormFields(String type) {
    switch (type) {
      case "habitation":
        return {"title": "Informations sur le logement", "fields": "Type de logement|Surface (m²)|Adresse"};
      case "sante":
        return {"title": "Informations personnelles", "fields": "Formule (Essentielle/Confort/Premium)|Âge|Antécédents médicaux"};
      case "voyage":
        return {"title": "Détails du voyage", "fields": "Destination|Date de départ|Date de retour|Nombre de voyageurs"};
      case "animaux":
        return {"title": "Informations sur l'animal", "fields": "Nom de l'animal|Type (Chien/Chat/Autre)|Âge|Race"};
      case "scolaire":
        return {"title": "Informations sur l'enfant", "fields": "Nom de l'enfant|Âge|Établissement scolaire|Classe"};
      case "pro":
        return {"title": "Informations professionnelles", "fields": "Nom de l'entreprise|Secteur d'activité|Nombre d'employés|Chiffre d'affaires annuel"};
      default:
        return {"title": "Informations", "fields": "Nom complet|Adresse"};
    }
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text("Demande d'assurance envoyée avec succès!"),
              ]),
              backgroundColor: AppColors.greenSuccess,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenSuccess,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColors.greenSuccess.withOpacity(0.3),
        ),
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: const Text("Souscrire", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
