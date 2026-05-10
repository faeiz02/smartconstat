import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/services/api_service_features.dart';

class AddInsuranceScreen extends StatelessWidget {
  const AddInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Demander une assurance"),
        backgroundColor: AppColors.greenSuccess,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.greenSuccess.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nouvelle demande",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Choisissez une offre et envoyez votre dossier",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceList(BuildContext context) {
    final assurances = <Map<String, dynamic>>[
      {
        "icon": Icons.home_outlined,
        "title": "Assurance Habitation",
        "color": AppColors.purpleAssistance,
        "desc": "Protegez votre logement",
        "prix": "300 DT/an",
        "garanties": ["Incendie", "Degat des eaux", "Vol", "Responsabilite civile"],
        "formType": "habitation",
      },
      {
        "icon": Icons.favorite_outline,
        "title": "Assurance Sante",
        "color": AppColors.redDanger,
        "desc": "Couverture medicale complete",
        "prix": "600 DT/an",
        "garanties": ["Consultations", "Hospitalisation", "Medicaments", "Dentaire"],
        "formType": "sante",
      },
      {
        "icon": Icons.flight_takeoff_rounded,
        "title": "Assurance Voyage",
        "color": AppColors.orangeWarning,
        "desc": "Voyagez en toute serenite",
        "prix": "80 DT/sejour",
        "garanties": ["Annulation", "Bagages", "Rapatriement", "Frais medicaux"],
        "formType": "voyage",
      },
      {
        "icon": Icons.pets_outlined,
        "title": "Assurance Animaux",
        "color": const Color(0xFF78350F),
        "desc": "Pour vos compagnons",
        "prix": "250 DT/an",
        "garanties": ["Soins veterinaires", "Chirurgie", "Medicaments", "Responsabilite civile"],
        "formType": "animaux",
      },
      {
        "icon": Icons.school_outlined,
        "title": "Assurance Scolaire",
        "color": AppColors.tealSoins,
        "desc": "Protection pour vos enfants",
        "prix": "150 DT/an",
        "garanties": ["Accident scolaire", "Responsabilite civile", "Assistance", "Frais medicaux"],
        "formType": "scolaire",
      },
      {
        "icon": Icons.work_outline,
        "title": "Assurance Professionnelle",
        "color": AppColors.secondaryBlue,
        "desc": "Pour votre activite",
        "prix": "800 DT/an",
        "garanties": ["Responsabilite civile pro", "Locaux", "Materiel", "Perte d'exploitation"],
        "formType": "pro",
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: assurances.length,
      itemBuilder: (context, index) {
        final assurance = assurances[index];
        final color = assurance["color"] as Color;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _InsuranceDetailScreen(assurance: assurance),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(assurance["icon"], color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assurance["title"],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        assurance["desc"],
                        style: const TextStyle(color: AppColors.mediumGrey, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          assurance["prix"],
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.scaffold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InsuranceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> assurance;
  const _InsuranceDetailScreen({required this.assurance});

  @override
  State<_InsuranceDetailScreen> createState() => _InsuranceDetailScreenState();
}

class _InsuranceDetailScreenState extends State<_InsuranceDetailScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  String get _formType => widget.assurance["formType"] ?? "";

  List<String> get _fieldLabels {
    final fields = _getFormFields(_formType)["fields"] as String;
    return fields.split("|").map((field) => field.trim()).toList();
  }

  @override
  void initState() {
    super.initState();
    for (final label in _fieldLabels) {
      _controllers[label] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.assurance["color"] as Color;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(widget.assurance["title"]),
        backgroundColor: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
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
            _buildForm(),
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
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.assurance["icon"], color: Colors.white, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            widget.assurance["title"],
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            widget.assurance["desc"],
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("A partir de ", style: TextStyle(fontSize: 15, color: AppColors.mediumGrey)),
          Text(
            widget.assurance["prix"],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildGarantiesCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Garanties incluses", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...(widget.assurance["garanties"] as List<String>).map((garantie) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.check_rounded, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      garantie,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final formFields = _getFormFields(_formType);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formFields["title"]!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ..._fieldLabels.map((fieldLabel) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _controllers[fieldLabel],
                decoration: InputDecoration(labelText: fieldLabel),
                keyboardType: _isNumericField(fieldLabel) ? TextInputType.number : TextInputType.text,
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<String, dynamic> _getFormFields(String type) {
    switch (type) {
      case "habitation":
        return {"title": "Informations sur le logement", "fields": "Type de logement|Surface (m2)|Adresse"};
      case "sante":
        return {"title": "Informations personnelles", "fields": "Formule (Essentielle/Confort/Premium)|Age|Antecedents medicaux"};
      case "voyage":
        return {"title": "Details du voyage", "fields": "Destination|Date de depart|Date de retour|Nombre de voyageurs"};
      case "animaux":
        return {"title": "Informations sur l'animal", "fields": "Nom de l'animal|Type (Chien/Chat/Autre)|Age|Race"};
      case "scolaire":
        return {"title": "Informations sur l'enfant", "fields": "Nom de l'enfant|Age|Etablissement scolaire|Classe"};
      case "pro":
        return {"title": "Informations professionnelles", "fields": "Nom de l'entreprise|Secteur d'activite|Nombre d'employes|Chiffre d'affaires annuel"};
      default:
        return {"title": "Informations", "fields": "Nom complet|Adresse"};
    }
  }

  bool _isNumericField(String fieldLabel) {
    return fieldLabel.contains("Surface") ||
        fieldLabel.contains("Age") ||
        fieldLabel.contains("Nombre") ||
        fieldLabel.contains("Chiffre");
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : () => _submitRequest(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenSuccess,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColors.greenSuccess.withOpacity(0.3),
        ),
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.check_circle_outline, size: 20),
        label: Text(
          _isSubmitting ? "Envoi..." : "Envoyer la demande",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _submitRequest(BuildContext context) async {
    final details = <String, String>{};
    final missingFields = <String>[];

    for (final label in _fieldLabels) {
      final value = _controllers[label]?.text.trim() ?? "";
      details[label] = value;
      if (value.isEmpty) {
        missingFields.add(label);
      }
    }

    if (missingFields.isNotEmpty) {
      _showSnackBar(
        context,
        "Veuillez remplir tous les champs de la demande.",
        AppColors.orangeWarning,
        Icons.info_outline,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await ApiServiceFeatures.submitInsuranceRequest(
      type: _formType,
      title: widget.assurance["title"],
      price: widget.assurance["prix"],
      details: details,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result["success"] == true) {
      _showSnackBar(
        context,
        result["message"] ?? "Demande envoyee avec succes.",
        AppColors.greenSuccess,
        Icons.check_circle,
      );
      final navigator = Navigator.of(context);
      navigator.pop();
      if (navigator.canPop()) {
        navigator.pop();
      }
      return;
    }

    _showSnackBar(
      context,
      result["message"] ?? "Impossible d'envoyer la demande.",
      AppColors.redDanger,
      Icons.error_outline,
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
