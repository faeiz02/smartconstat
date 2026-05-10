import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CustomScrollView(
        slivers: [
          // ─── Sliver AppBar with profile header ───
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditDialog(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentCyan.withOpacity(0.25),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.accentCyan.withOpacity(0.3),
                          child: Text(
                            _getInitials(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${user.nom} ${user.prenom}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "ID: ${user.assuranceId}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Body content ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats row
                  Row(
                    children: [
                      Expanded(child: _buildStatTile("Constats", "3", Icons.description_outlined, AppColors.secondaryBlue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatTile("Assurances", "2", Icons.shield_outlined, AppColors.greenSuccess)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatTile("Sinistres", "1", Icons.warning_amber_rounded, AppColors.orangeWarning)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    title: "Informations personnelles",
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildInfoRow(Icons.badge_outlined, "CIN", user.cin),
                      _buildInfoRow(Icons.phone_outlined, "Téléphone", user.phone),
                      _buildInfoRow(Icons.email_outlined, "Email", user.email),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildInfoCard(
                    title: "Informations véhicule",
                    icon: Icons.directions_car_outlined,
                    children: [
                      _buildInfoRow(Icons.car_rental_outlined, "Marque", user.vehicleBrand),
                      _buildInfoRow(Icons.model_training, "Modèle", user.vehicleModel),
                      _buildInfoRow(Icons.pin_outlined, "Matricule", user.vehiclePlate),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildInfoCard(
                    title: "Assurance",
                    icon: Icons.shield_outlined,
                    children: [
                      _buildInfoRow(Icons.assignment_ind_outlined, "N° contrat", user.insuranceNumber),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Security badge
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondaryBlue.withOpacity(0.08), AppColors.accentCyan.withOpacity(0.06)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, color: AppColors.secondaryBlue, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Données sécurisées — Chiffrement AES-256",
                          style: TextStyle(
                            color: AppColors.secondaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await context.read<UserProvider>().clearUser();
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          context.go('/');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redDanger.withOpacity(0.1),
                        foregroundColor: AppColors.redDanger,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        "Se déconnecter",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    final n = user.nom.isNotEmpty ? user.nom[0].toUpperCase() : '';
    final p = user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : '';
    return '$n$p';
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.secondaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.mediumGrey),
          const SizedBox(width: 12),
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mediumGrey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkGrey),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final phoneController = TextEditingController(text: user.phone);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.secondaryBlue, size: 22),
              SizedBox(width: 8),
              Text("Modifier le profil"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Téléphone",
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            FilledButton.icon(
              onPressed: () async {
                // Mise à jour via API REST
                await AuthService.updateProfile({
                  'phone': phoneController.text,
                  'email': emailController.text,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text("Profil mis à jour"),
                      ],
                    ),
                    backgroundColor: AppColors.greenSuccess,
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }
}
