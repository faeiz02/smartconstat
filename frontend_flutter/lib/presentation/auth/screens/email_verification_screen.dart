import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  void verifyCode() async {
    if (codeController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer le code à 6 chiffres")),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await AuthService.verifyEmailCode(widget.email, codeController.text);

    setState(() => isLoading = false);

    if (response["success"] == true) {
      final userData = response["user"] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      if (!mounted) return;
      context.read<AuthProvider>().setAuthenticatedUser(user);
      context.read<UserProvider>().setUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email vérifié avec succès !"),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/home', extra: user);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? "Erreur de vérification"),
          backgroundColor: AppColors.redDanger,
        ),
      );
    }
  }

  void resendCode() async {
    final response = await AuthService.resendVerificationCode(widget.email);
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['message'] ?? "Code renvoyé"),
        backgroundColor: response["success"] == true ? Colors.green : AppColors.redDanger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050D1F), Color(0xFF0F2B5B), Color(0xFF1E4FA0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Vérification Email",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Un code PIN de 6 chiffres a été envoyé à :\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: TextField(
                            controller: codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              letterSpacing: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              filled: false,
                              hintText: "000000",
                              hintStyle: TextStyle(color: Colors.white30, letterSpacing: 8),
                              counterText: "",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    "Vérifier",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: resendCode,
                          child: Text(
                            "Renvoyer le code",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
