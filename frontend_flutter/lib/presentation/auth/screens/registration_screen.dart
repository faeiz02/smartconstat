import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> insuranceData;
  const RegistrationScreen({super.key, required this.insuranceData});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();

  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    // Pre-fill fields from insurance data
    final data = widget.insuranceData;
    _nomController.text = data['nom'] ?? '';
    _prenomController.text = data['prenom'] ?? '';
    _phoneController.text = data['phone'] ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _register() async {
    // Validation
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nomController.text.isEmpty ||
        _prenomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires"),
          backgroundColor: AppColors.redDanger,
        ),
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer une adresse email valide"),
          backgroundColor: AppColors.redDanger,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le mot de passe doit contenir au moins 6 caractères"),
          backgroundColor: AppColors.redDanger,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Les mots de passe ne correspondent pas"),
          backgroundColor: AppColors.redDanger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        assuranceId: widget.insuranceData['assuranceId'] ?? '',
        cin: widget.insuranceData['cin'] ?? '',
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        phone: _phoneController.text.trim(),
        vehicleBrand: widget.insuranceData['vehicleBrand'] ?? '',
        vehicleModel: widget.insuranceData['vehicleModel'] ?? '',
        vehiclePlate: widget.insuranceData['vehiclePlate'] ?? '',
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success'] == true) {
          // Inscription réussie → aller à la vérification d'email
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.mark_email_unread, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text("Compte créé ! Vérifiez votre email."),
                ],
              ),
              backgroundColor: AppColors.primaryBlue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.go('/verify-email', extra: _emailController.text.trim());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result['message'] ?? "Erreur lors de l'inscription"),
              backgroundColor: AppColors.redDanger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: AppColors.redDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.insuranceData;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050D1F), Color(0xFF0F2B5B), Color(0xFF1E4FA0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenSuccess.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentCyan.withOpacity(0.06),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Back button row
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () => context.go('/insurance-verification'),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Retour",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.successGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.greenSuccess
                                          .withOpacity(0.3),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                    Icons.person_add_alt_1_rounded,
                                    size: 40,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Créer votre compte",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Complétez vos informations",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),

                              // Insurance badge
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.greenSuccess.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        AppColors.greenSuccess.withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded,
                                        color: AppColors.greenSuccess,
                                        size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Assurance: ${data['assuranceId'] ?? ''}",
                                      style: const TextStyle(
                                        color: AppColors.greenSuccess,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Glass card - Registration form
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.12)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Section: Personal info
                                        _buildSectionTitle(
                                            Icons.person_outline_rounded,
                                            "Informations personnelles"),
                                        const SizedBox(height: 16),

                                        // Nom
                                        _buildInputField(
                                          controller: _nomController,
                                          hint: "Nom *",
                                          icon: Icons.person_outline,
                                        ),
                                        const SizedBox(height: 12),

                                        // Prenom
                                        _buildInputField(
                                          controller: _prenomController,
                                          hint: "Prénom *",
                                          icon: Icons.person_outline,
                                        ),
                                        const SizedBox(height: 12),

                                        // Phone
                                        _buildInputField(
                                          controller: _phoneController,
                                          hint: "Téléphone",
                                          icon: Icons.phone_outlined,
                                          keyboardType: TextInputType.phone,
                                        ),

                                        const SizedBox(height: 28),

                                        // Section: Account info
                                        _buildSectionTitle(
                                            Icons.lock_outline_rounded,
                                            "Informations du compte"),
                                        const SizedBox(height: 16),

                                        // Email
                                        _buildInputField(
                                          controller: _emailController,
                                          hint: "Adresse email *",
                                          icon: Icons.email_outlined,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                        const SizedBox(height: 12),

                                        // Password
                                        _buildPasswordField(
                                          controller: _passwordController,
                                          hint:
                                              "Mot de passe * (min. 6 caractères)",
                                          icon: Icons.lock_outline_rounded,
                                          obscure: _obscure1,
                                          onToggle: () => setState(
                                              () => _obscure1 = !_obscure1),
                                        ),
                                        const SizedBox(height: 12),

                                        // Confirm password
                                        _buildPasswordField(
                                          controller:
                                              _confirmPasswordController,
                                          hint: "Confirmer le mot de passe *",
                                          icon: Icons.lock_reset_rounded,
                                          obscure: _obscure2,
                                          onToggle: () => setState(
                                              () => _obscure2 = !_obscure2),
                                        ),

                                        const SizedBox(height: 28),

                                        // Vehicle info (read-only)
                                        if ((data['vehicleBrand'] ?? '')
                                            .toString()
                                            .isNotEmpty) ...[
                                          _buildSectionTitle(
                                              Icons.directions_car_outlined,
                                              "Véhicule assuré"),
                                          const SizedBox(height: 12),
                                          _buildReadOnlyInfo(
                                            "${data['vehicleBrand']} ${data['vehicleModel'] ?? ''}",
                                            Icons.directions_car_outlined,
                                          ),
                                          if ((data['vehiclePlate'] ?? '')
                                              .toString()
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            _buildReadOnlyInfo(
                                              data['vehiclePlate'],
                                              Icons
                                                  .confirmation_number_outlined,
                                            ),
                                          ],
                                          const SizedBox(height: 24),
                                        ],

                                        // Register button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 56,
                                          child: ElevatedButton(
                                            onPressed:
                                                _isLoading ? null : _register,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.greenSuccess,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              elevation: 4,
                                              shadowColor: AppColors
                                                  .greenSuccess
                                                  .withOpacity(0.4),
                                            ),
                                            child: _isLoading
                                                ? const SizedBox(
                                                    height: 22,
                                                    width: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                                  )
                                                : const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "CRÉER MON COMPTE",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Icon(
                                                          Icons
                                                              .check_circle_outline_rounded,
                                                          size: 20),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentCyan.withOpacity(0.8), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyInfo(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentCyan.withOpacity(0.7), size: 18),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.mediumGrey.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.secondaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.mediumGrey.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.secondaryBlue),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.mediumGrey,
            ),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
