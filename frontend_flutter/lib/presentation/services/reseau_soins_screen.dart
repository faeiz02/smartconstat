import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/api_service_features.dart';
import 'healthcare_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ReseauSoinsScreen extends StatefulWidget {
  const ReseauSoinsScreen({super.key});

  @override
  State<ReseauSoinsScreen> createState() => _ReseauSoinsScreenState();
}

class _ReseauSoinsScreenState extends State<ReseauSoinsScreen> {
  late Future<List<dynamic>> _dataFuture;
  String? _selectedCategory;
  String _searchQuery = "";
  List<dynamic> _allPros = [];

  @override
  void initState() {
    super.initState();
    _dataFuture = ApiServiceFeatures.getReseauSoins();
  }

  Future<void> _launchPhone(String phoneStr) async {
    final phone = phoneStr.replaceAll(" ", "");
    if (phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text("Réseau de soins"),
        backgroundColor: AppColors.tealSoins,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 20),
            FutureBuilder<List<dynamic>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.tealSoins)),
                  );
                } else if (snapshot.hasError) {
                   return const Center(child: Text("Erreur de chargement"));
                }

                _allPros = snapshot.data ?? [];
                
                // Calculer les catégories dynamiquement
                final Map<String, int> counts = {};
                for (var p in _allPros) {
                  String type = p['type'] ?? "Inconnu";
                  counts[type] = (counts[type] ?? 0) + 1;
                }

                final categories = counts.entries.map((e) {
                  IconData icon = Icons.medical_services_outlined;
                  if (e.key.contains("Dentiste")) icon = Icons.health_and_safety_outlined;
                  if (e.key.contains("Généraliste")) icon = Icons.medical_services_outlined;
                  if (e.key.contains("Psychologue")) icon = Icons.psychology_outlined;
                  if (e.key.contains("Cardiologue")) icon = Icons.monitor_heart_outlined;
                  if (e.key.contains("Clinique")) icon = Icons.local_hospital_outlined;

                  return {
                    "icon": icon,
                    "name": e.key,
                    "count": e.value
                  };
                }).toList();

                // Filtrer les professionnels par catégorie et recherche
                final displayedPros = _allPros.where((p) {
                  final matchesCategory = _selectedCategory == null || p['type'] == _selectedCategory;
                  final name = (p['name'] ?? "").toString().toLowerCase();
                  final typeStr = (p['type'] ?? "").toString().toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  final matchesSearch = query.isEmpty || name.contains(query) || typeStr.contains(query);
                  return matchesCategory && matchesSearch;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (categories.isNotEmpty) _buildCategoriesList(categories),
                    const SizedBox(height: 20),
                    _buildProfessionnelsList(displayedPros),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.tealSoins, Color(0xFF2DD4BF)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.tealSoins.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Professionnels de santé", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text("Trouvez un médecin ou une clinique", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.local_hospital_outlined, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Rechercher un professionnel...",
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.tealSoins),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true, fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategoriesList(List<Map<String, dynamic>> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Catégories", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (_selectedCategory != null)
              GestureDetector(
                onTap: () => setState(() => _selectedCategory = null),
                child: const Text("Voir tout", style: TextStyle(color: AppColors.tealSoins, fontWeight: FontWeight.w600, fontSize: 13)),
              )
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 106,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final c = categories[i];
              final isSelected = _selectedCategory == c["name"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedCategory == c["name"]) {
                      _selectedCategory = null;
                    } else {
                      _selectedCategory = c["name"] as String;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tealSoins : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.tealSoins : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(c["icon"] as IconData, color: isSelected ? Colors.white : AppColors.tealSoins, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        c["name"] as String, 
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.black87), 
                        textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${c["count"]}", 
                        style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : AppColors.mediumGrey)
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionnelsList(List<dynamic> pros) {
    if (pros.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Aucun professionnel trouvé dans cette catégorie.", textAlign: TextAlign.center),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("À proximité", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...pros.map((p) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HealthcareDetailScreen(professional: p as Map<String, dynamic>)),
            );
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
                  decoration: BoxDecoration(color: AppColors.tealSoins.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(
                    (p["type"] == "Clinique") ? Icons.local_hospital_outlined : Icons.person_outline,
                    color: AppColors.tealSoins, size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(p["type"] ?? "", style: const TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
                      Text("${p["address"] ?? ""} • ${p["distanceStr"] ?? ""}", style: TextStyle(color: AppColors.mediumGrey.withOpacity(0.7), fontSize: 11)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _launchPhone(p["phone"] ?? ""),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.tealSoins.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.phone_outlined, color: AppColors.tealSoins, size: 18),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}