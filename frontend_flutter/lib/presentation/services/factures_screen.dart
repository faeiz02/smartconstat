import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/api_service_features.dart';

class FacturesScreen extends StatefulWidget {
  const FacturesScreen({super.key});

  @override
  State<FacturesScreen> createState() => _FacturesScreenState();
}

class _FacturesScreenState extends State<FacturesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allFactures = [];
  List<dynamic> _dossiers = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Toutes', 'type': null, 'icon': Icons.list_alt_rounded},
    {'label': 'Maladie', 'type': 'Maladie', 'icon': Icons.local_hospital_outlined},
    {'label': 'Réparation', 'type': 'Réparation', 'icon': Icons.build_outlined},
    {'label': 'Visite tech.', 'type': 'Visite technique', 'icon': Icons.directions_car_outlined},
    {'label': 'Autre', 'type': 'Autre', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() { if (!_tabController.indexIsChanging) setState(() {}); });
    _loadFactures();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFactures() async {
    setState(() => _isLoading = true);
    final factures = await ApiServiceFeatures.getFactures();
    final dossiers = await ApiServiceFeatures.getMyConstats();
    if (mounted) {
      setState(() {
        _allFactures = factures;
        _dossiers = dossiers.where(_isFactureDossier).toList();
        _isLoading = false;
      });
    }
  }

  bool _isFactureDossier(dynamic constat) {
    final statut = (constat['statut'] ?? '').toString().toLowerCase();
    final factureStatut = (constat['factureStatut'] ?? '').toString().toLowerCase();
    return statut.contains('trait') ||
        statut.contains('expertise') ||
        (factureStatut.isNotEmpty && factureStatut != 'non demandee');
  }

  List<dynamic> _getFilteredFactures() {
    final type = _categories[_tabController.index]['type'];
    if (type == null) return _allFactures;
    return _allFactures.where((f) => f['typeFacture'] == type).toList();
  }

  Future<void> _deleteFacture(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer la facture ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.redDanger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ApiServiceFeatures.deleteFacture(id);
      if (success) {
        _loadFactures();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facture supprimée'), backgroundColor: AppColors.greenSuccess));
      }
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'Maladie': return Icons.local_hospital_outlined;
      case 'Réparation': return Icons.build_outlined;
      case 'Visite technique': return Icons.directions_car_outlined;
      default: return Icons.receipt_long_outlined;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'Maladie': return AppColors.redDanger;
      case 'Réparation': return AppColors.orangeWarning;
      case 'Visite technique': return AppColors.secondaryBlue;
      default: return AppColors.brownFactures;
    }
  }

  Color _getStatusColor(String? statut) {
    final value = (statut ?? '').toLowerCase();
    if (value.contains('prise') || value.contains('payée') || value.contains('payee')) return AppColors.greenSuccess;
    if (value.contains('expertise')) return AppColors.secondaryBlue;
    if (value.contains('rejet')) return AppColors.redDanger;
    return AppColors.orangeWarning;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Mes factures"),
        backgroundColor: AppColors.brownFactures,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: _categories.map((c) => Tab(icon: Icon(c['icon'], size: 20), text: c['label'])).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brownFactures))
          : RefreshIndicator(
              onRefresh: _loadFactures,
              child: _buildBody(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateFactureDialog,
        backgroundColor: AppColors.brownFactures,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ajouter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showCreateFactureDialog() {
    final moisCtrl = TextEditingController();
    final montantCtrl = TextEditingController();
    String selectedType = 'Maladie';
    int? selectedConstatId = _dossiers.isNotEmpty
        ? int.tryParse((_dossiers.first['id'] ?? _dossiers.first['accidentId']).toString())
        : null;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text("Nouvelle facture", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              TextField(
                controller: moisCtrl,
                decoration: InputDecoration(
                  labelText: "Mois / Libellé",
                  hintText: "Ex: Janvier 2026",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montantCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Montant (DT)",
                  hintText: "Ex: 150.00",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: InputDecoration(
                  labelText: "Type de facture",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: ['Maladie', 'Réparation', 'Visite technique', 'Autre'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setModalState(() => selectedType = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: selectedConstatId,
                decoration: InputDecoration(
                  labelText: "Dossier constat",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.folder_copy_outlined),
                ),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text("Sans dossier")),
                  ..._dossiers.map((d) {
                    final id = int.tryParse((d['id'] ?? d['accidentId']).toString());
                    final label = "Constat #${d['accidentId'] ?? d['id']} - ${d['factureStatut'] ?? d['statut'] ?? ''}";
                    return DropdownMenuItem<int?>(value: id, child: Text(label, overflow: TextOverflow.ellipsis));
                  }),
                ],
                onChanged: (v) => setModalState(() => selectedConstatId = v),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setModalState(() => selectedDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Échéance",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.event),
                  ),
                  child: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setModalState(() => selectedImage = File(pickedFile.path));
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Image de la facture (optionnel)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.image_outlined),
                  ),
                  child: Text(
                    selectedImage != null ? selectedImage!.path.split('/').last : "Ajouter une image",
                    style: TextStyle(color: selectedImage != null ? AppColors.greenSuccess : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (moisCtrl.text.isEmpty || montantCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs")));
                      return;
                    }
                    final echeanceStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                    final factureId = await ApiServiceFeatures.createFacture(
                      mois: moisCtrl.text,
                      montant: double.tryParse(montantCtrl.text) ?? 0,
                      echeance: echeanceStr,
                      typeFacture: selectedType,
                      constatId: selectedConstatId,
                    );
                    if (mounted) Navigator.pop(ctx);
                    if (factureId != -1) {
                      if (selectedImage != null) {
                        final uploadSuccess = await ApiServiceFeatures.uploadFacturePhoto(factureId, selectedImage!.path);
                        if (uploadSuccess) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Facture et image ajoutées ✓"), backgroundColor: AppColors.greenSuccess));
                        } else {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Facture ajoutée, mais erreur d'image"), backgroundColor: AppColors.orangeWarning));
                        }
                      } else {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Facture ajoutée ✓"), backgroundColor: AppColors.greenSuccess));
                      }
                      _loadFactures();
                    } else {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de l'ajout"), backgroundColor: AppColors.redDanger));
                    }
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Créer la facture", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brownFactures,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final factures = _getFilteredFactures();
    double totalPaye = 0;
    double aPayer = 0;
    for (var f in factures) {
      final statut = (f['statut'] ?? '').toString().toLowerCase();
      if (statut.contains('payée') || statut.contains('payee') || statut.contains('prise')) {
        totalPaye += (f['montant'] as num).toDouble();
      } else {
        aPayer += (f['montant'] as num).toDouble();
      }
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
                Text("Consultez et gérez vos factures", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
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
          Text(label, style: const TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFacturesList(List<dynamic> factures) {
    if (factures.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text("Aucune facture dans cette catégorie", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(children: factures.map((f) {
      final color = _getStatusColor(f["statut"]?.toString());
      final typeColor = _getTypeColor(f['typeFacture']);
      final typeIcon = _getTypeIcon(f['typeFacture']);
      final factureId = f['id'];

      return Dismissible(
        key: Key('facture_$factureId'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: AppColors.redDanger,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        confirmDismiss: (_) async {
          await _deleteFacture(factureId);
          return false; // We handle refresh manually
        },
        child: Container(
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
                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f["mois"] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(f['typeFacture'] ?? 'Autre', style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                        Text("Éch: ${f["echeance"] ?? ''}", style: const TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                      ],
                    ),
                    if (f["constatId"] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Dossier constat #${f["constatId"]}",
                        style: const TextStyle(color: AppColors.darkGrey, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (f["priseEnChargeDecision"] != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        f["priseEnChargeDecision"].toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.mediumGrey, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${f["montant"]} DT", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(f["statut"] ?? '', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  if (f["photoUrl"] != null) ...[
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            child: InteractiveViewer(
                              child: Image.network("${ApiConstants.backendUrl}/${f["photoUrl"]}"),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.secondaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.image, size: 16, color: AppColors.secondaryBlue),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }).toList());
  }
}
