import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/constat_model.dart';
import '../../../data/models/accident_model.dart';
import '../../../data/services/accident_service.dart';
import '../../accident/screens/accident_result_screen.dart';
import '../../../utils/date_formatter.dart';
import '../../../core/constants/app_colors.dart';

class MyConstatsScreen extends StatefulWidget {
  final UserModel user;
  const MyConstatsScreen({super.key, required this.user});

  @override
  State<MyConstatsScreen> createState() => _MyConstatsScreenState();
}

class _MyConstatsScreenState extends State<MyConstatsScreen> {
  List<ConstatModel> _allConstats = [];
  List<ConstatModel> _filteredConstats = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConstats();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConstats() async {
    final constats = await AccidentService.getUserConstats(widget.user.assuranceId);
    if (mounted) {
      setState(() {
        _allConstats = constats;
        _filteredConstats = constats;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConstats = _allConstats.where((constat) {
        final lieuMatch = constat.lieu?.toLowerCase().contains(query) ?? false;
        final immatMatch = constat.immatriculationA?.toLowerCase().contains(query) ?? false;
        final dateStr = constat.dateTime != null ? DateFormatter.formatDate(constat.dateTime!).toLowerCase() : "";
        final dateMatch = dateStr.contains(query);
        return lieuMatch || immatMatch || dateMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Mes Constats", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: Column(
        children: [
          _buildHeaderCard(),
          _buildSearchBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Historique complet", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Gérez et suivez vos déclarations", style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.history_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Rechercher (lieu, plaque, date)...",
          hintStyle: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allConstats.isEmpty) {
      return _buildEmptyState("Vous n'avez soumis aucun constat pour le moment.");
    }

    if (_filteredConstats.isEmpty) {
      return _buildEmptyState("Aucun constat ne correspond à votre recherche.");
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredConstats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final constat = _filteredConstats[index];
        final status = constat.statut ?? "En cours d'analyse";
        
        Color statusColor;
        Color statusBg;
        if (status.toLowerCase().contains("traité") || status.toLowerCase().contains("validé")) {
          statusColor = AppColors.greenSuccess;
          statusBg = AppColors.greenSuccess.withOpacity(0.1);
        } else if (status.toLowerCase().contains("refusé")) {
          statusColor = AppColors.redDanger;
          statusBg = AppColors.redDanger.withOpacity(0.1);
        } else {
          statusColor = AppColors.orangeWarning;
          statusBg = AppColors.orangeWarning.withOpacity(0.1);
        }

        final AccidentModel adapterModel = AccidentModel(
          id: constat.accidentId ?? "N/A",
          date: constat.dateTime ?? DateTime.now(),
          lieu: constat.lieu ?? "Inconnu",
          status: status,
          responsabilite: "En analyse",
          immatriculation: constat.immatriculationA ?? "N/A",
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccidentResultScreen(accident: adapterModel),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.secondaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.assignment_outlined, color: AppColors.secondaryBlue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        constat.lieu ?? "Lieu non précisé",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        constat.dateTime != null ? DateFormatter.formatDate(constat.dateTime!) : "Date inconnue",
                        style: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                        child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.mediumGrey),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
