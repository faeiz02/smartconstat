import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/models/constat_model.dart';
import '../../data/models/accident_model.dart'; // Conservé pour compatibilité avec AccidentResultScreen
import '../../data/services/accident_service.dart';
import '../constat/screens/constat_form_screen.dart';
import '../accident/screens/accident_result_screen.dart';
import '../constat/screens/my_constats_screen.dart';
import '../profile/profile_screen.dart';
import '../services/assistance_voyage_screen.dart';
import '../services/reseau_soins_screen.dart';
import '../services/assistance_247_screen.dart';
import '../services/factures_screen.dart';
import '../insurance/add_insurance_screen.dart';
import '../../utils/date_formatter.dart';
import '../../core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late DateTime _dateDebut;
  late DateTime _dateFin;

  List<ConstatModel> _constats = [];
  bool _isLoadingConstats = true;

  @override
  void initState() {
    super.initState();
    _dateFin = widget.user.dateExpiration ?? DateTime.now().add(const Duration(days: 365));
    _dateDebut = DateTime(_dateFin.year - 1, _dateFin.month, _dateFin.day);
    _loadConstats();
  }

  Future<void> _loadConstats() async {
    final constats = await AccidentService.getUserConstats(widget.user.assuranceId);
    if (mounted) {
      setState(() {
        _constats = constats;
        _isLoadingConstats = false;
      });
    }
  }

  bool _isInsuranceExpiringSoon() {
    final daysLeft = DateFormatter.getDaysLeft(_dateFin);
    return daysLeft <= 30 && daysLeft > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 72,
            floating: true,
            snap: true,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield_outlined, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text(
                  "SmartConstat",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.5),
                ),
              ],
            ),
            actions: [
              if (_isInsuranceExpiringSoon())
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => _showExpirationDialog(context),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.redDanger,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${DateFormatter.getDaysLeft(_dateFin)}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () => _showMessage(context, "Aucune notification", AppColors.mediumGrey),
                ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.user))),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.accentCyan.withOpacity(0.3),
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildAccueilScreen(),
            _buildAssuranceScreen(),
            _buildServicesScreen(),
            _buildContactScreen(),
          ],
        ),
      ),
      // Modern bottom nav
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.secondaryBlue,
            unselectedItemColor: AppColors.mediumGrey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: [
              _buildNavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, "Accueil"),
              _buildNavItem(Icons.verified_user_rounded, Icons.verified_user_outlined, "Assurance"),
              _buildNavItem(Icons.widgets_rounded, Icons.widgets_outlined, "Services"),
              _buildNavItem(Icons.support_agent_rounded, Icons.support_agent_outlined, "Contact"),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddInsuranceScreen())),
              icon: const Icon(Icons.add_rounded),
              label: const Text("Ajouter", style: TextStyle(fontWeight: FontWeight.w700)),
              backgroundColor: AppColors.greenSuccess,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            )
          : null,
    );
  }

  String _getInitials() {
    final n = widget.user.nom.isNotEmpty ? widget.user.nom[0].toUpperCase() : '';
    final p = widget.user.prenom.isNotEmpty ? widget.user.prenom[0].toUpperCase() : '';
    return '$n$p';
  }

  BottomNavigationBarItem _buildNavItem(IconData selected, IconData unselected, String label) {
    return BottomNavigationBarItem(
      icon: Icon(unselected),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.secondaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(selected),
      ),
      label: label,
    );
  }

  // ==================== ACCUEIL ====================
  Widget _buildAccueilScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 16),
          _buildInsuranceCard(),
          const SizedBox(height: 16),
          _buildConstatsList(),
          const SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryBlue.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour ${widget.user.prenom} 👋",
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Gérez vos assurances et constats\nen toute simplicité",
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13, height: 1.4),
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
                child: const Icon(Icons.car_crash_outlined, color: Colors.white, size: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard() {
    final daysLeft = DateFormatter.getDaysLeft(_dateFin);
    final progress = DateFormatter.getProgressPercentage(_dateDebut, _dateFin);
    final progressColor = daysLeft < 30 ? AppColors.orangeWarning : AppColors.greenSuccess;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.secondaryBlue, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Mon assurance auto",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$daysLeft jrs",
                  style: TextStyle(color: progressColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Début", style: TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(DateFormatter.formatDate(_dateDebut), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Échéance", style: TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(
                      DateFormatter.formatDate(_dateFin),
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: progressColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.lightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${(progress * 100).toStringAsFixed(0)}% écoulé",
            style: TextStyle(color: AppColors.mediumGrey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildConstatsList() {
    if (_isLoadingConstats) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_constats.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: const Text("Aucun constat soumis pour le moment.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.mediumGrey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Dernier constat", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (_constats.length > 1)
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyConstatsScreen(user: widget.user))),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("Voir tout", style: TextStyle(color: AppColors.secondaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _constats.take(1).length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final constat = _constats[index];
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccidentResultScreen(accident: adapterModel))),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.description_outlined, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                constat.dateTime != null ? DateFormatter.formatDate(constat.dateTime!) : "Date inconnue",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            constat.lieu ?? "Lieu non spécifié",
                            style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tiers: ${constat.immatriculationB ?? 'N/A'}",
                            style: TextStyle(color: AppColors.darkGrey, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Actions rapides", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.description_outlined,
                label: "Nouveau\nconstat",
                gradient: AppColors.successGradient,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConstatFormScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history_rounded,
                label: "Historique\nconstats",
                gradient: AppColors.primaryGradient,
                onTap: () => _showHistoriqueDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ASSURANCE ====================
  Widget _buildAssuranceScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Mes assurances", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        _buildAssuranceCard(
          title: widget.user.compagnie?.isNotEmpty == true ? widget.user.compagnie! : "Assurance auto",
          icon: Icons.directions_car_outlined,
          color: AppColors.secondaryBlue,
          numero: "AUTO-${widget.user.insuranceNumber}",
          type: "Rattrapé de la BDD",
          prime: "---",
          dateDebut: _dateDebut,
          dateFin: _dateFin,
        ),
      ],
    );
  }

  Widget _buildAssuranceCard({
    required String title,
    required IconData icon,
    required Color color,
    required String numero,
    required String type,
    required String prime,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(type, style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  prime,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("N° contrat", style: TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                  Text(numero, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Échéance", style: TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
                  Text(DateFormatter.formatDate(dateFin), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SERVICES ====================
  Widget _buildServicesScreen() {
    final List<Map<String, dynamic>> services = [
      {"icon": Icons.history_rounded, "title": "Mes Constats", "color": AppColors.primaryBlue, "screen": MyConstatsScreen(user: widget.user)},
      {"icon": Icons.description_outlined, "title": "Constat", "color": AppColors.secondaryBlue, "screen": const ConstatFormScreen()},
      {"icon": Icons.flight_takeoff_rounded, "title": "Assist. Voyage", "color": AppColors.orangeWarning, "screen": const AssistanceVoyageScreen()},
      {"icon": Icons.local_hospital_outlined, "title": "Réseau soins", "color": AppColors.tealSoins, "screen": const ReseauSoinsScreen()},
      {"icon": Icons.support_agent_rounded, "title": "Assistance 24/7", "color": AppColors.purpleAssistance, "screen": const Assistance247Screen()},
      {"icon": Icons.receipt_long_outlined, "title": "Mes factures", "color": AppColors.brownFactures, "screen": const FacturesScreen()},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tous nos services", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final s = services[index];
              return _buildServiceCard(
                icon: s["icon"],
                title: s["title"],
                color: s["color"],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => s["screen"])),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CONTACT ====================
  Widget _buildContactScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildContactCard(),
          const SizedBox(height: 16),
          _buildEmergencyCard(),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContactRow(
            icon: Icons.phone_outlined,
            iconColor: AppColors.secondaryBlue,
            title: "Service client",
            subtitle: "+216 71 123 456",
            btnLabel: "Appeler",
            btnColor: AppColors.greenSuccess,
            onPressed: () => _launchPhone("+21671123456"),
          ),
          const Divider(height: 20),
          _buildContactRow(
            icon: Icons.email_outlined,
            iconColor: AppColors.orangeWarning,
            title: "Email",
            subtitle: "contact@smartconstat.tn",
            btnLabel: "Envoyer",
            btnColor: AppColors.secondaryBlue,
            onPressed: () => _launchEmail("contact@smartconstat.tn"),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String btnLabel,
    required Color btnColor,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle, style: TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            minimumSize: Size.zero,
          ),
          child: Text(btnLabel, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.dangerGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.redDanger.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emergency_outlined, color: Colors.white, size: 36),
          const SizedBox(height: 10),
          const Text("URGENCE 24h/24", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text("1970", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text("Numéro d'urgence gratuit", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _launchPhone("1970"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.redDanger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            icon: const Icon(Icons.call, size: 18),
            label: const Text("Appeler maintenant", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ==================== DIALOGUES ====================
  void _showExpirationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.orangeWarning),
          SizedBox(width: 8),
          Text("Assurance bientôt expirée"),
        ]),
        content: Text(
          "Votre assurance automobile expire dans ${DateFormatter.getDaysLeft(_dateFin)} jours.\nPensez à la renouveler pour rester couvert.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Plus tard")),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRenewalDialog(context);
            },
            child: const Text("Renouveler"),
          ),
        ],
      ),
    );
  }

  void _showRenewalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Renouvellement"),
        content: const Text("Souhaitez-vous renouveler votre assurance pour 850 DT ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showMessage(context, "✅ Renouvellement effectué avec succès!", AppColors.greenSuccess);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.greenSuccess),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }

  void _showHistoriqueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.history_rounded, color: AppColors.secondaryBlue),
          SizedBox(width: 8),
          Text("Historique"),
        ]),
        content: SizedBox(
          width: double.maxFinite,
          child: _isLoadingConstats 
            ? const Center(child: CircularProgressIndicator())
            : _constats.isEmpty 
              ? const Text("Aucun constat enregistré.")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _constats.map((c) => _buildHistoryTile(
                    "Constat du ${c.dateTime != null ? DateFormatter.formatDate(c.dateTime!) : '?'}",
                    c.lieu ?? "Inconnu",
                    AppColors.secondaryBlue,
                    Icons.assignment_outlined,
                  )).toList(),
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fermer")),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String title, String subtitle, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: TextStyle(color: AppColors.mediumGrey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        _showMessage(context, "Impossible de lancer l'appel.", AppColors.redDanger);
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        _showMessage(context, "Impossible d'ouvrir la messagerie.", AppColors.redDanger);
      }
    }
  }
}