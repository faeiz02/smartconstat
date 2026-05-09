package com.smartconstat.service;

import com.smartconstat.dto.*;
import com.smartconstat.model.Assurance;
import com.smartconstat.model.PasswordResetToken;
import com.smartconstat.model.User;
import com.smartconstat.repository.AssuranceRepository;
import com.smartconstat.repository.PasswordResetTokenRepository;
import com.smartconstat.repository.UserRepository;
import java.security.SecureRandom;
import com.smartconstat.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final AssuranceRepository assuranceRepository;
    private final PasswordResetTokenRepository resetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final EmailService emailService;

    @org.springframework.beans.factory.annotation.Value("${app.admin.email:sarra@smartconstat.tn}")
    private String adminEmail;

    @org.springframework.beans.factory.annotation.Value("${app.admin.password:admin123}")
    private String adminPassword;

    @org.springframework.beans.factory.annotation.Value("${app.employe.email:employe@smartconstat.tn}")
    private String employeEmail;

    @org.springframework.beans.factory.annotation.Value("${app.employe.password:employe123}")
    private String employePassword;

    @jakarta.annotation.PostConstruct
    public void initAccounts() {
        // ─── Compte Admin ───
        try {
            Optional<User> opt = userRepository.findByEmail(adminEmail);
            User admin = opt.orElseGet(User::new);
            
            if (opt.isEmpty()) {
                admin.setEmail(adminEmail);
                admin.setNom("Ben Ali");
                admin.setPrenom("Sarra");
                admin.setCin("ADMIN001");
                admin.setPhone("0600000000");
                admin.setAssuranceId("ADMIN_SARRA");
            }
            
            admin.setPasswordHash(passwordEncoder.encode(adminPassword));
            admin.setRole("admin");
            admin.setVerified(true);
            userRepository.save(admin);
            
            System.out.println("==================================================");
            System.out.println("✅ COMPTE ADMIN PRÊT !");
            System.out.println("   Email: " + adminEmail);
            System.out.println("==================================================");
        } catch (Exception e) {
            System.err.println("Impossible de configurer le compte admin: " + e.getMessage());
        }

        // ─── Compte Employé ───
        try {
            Optional<User> optEmp = userRepository.findByEmail(employeEmail);
            User employe = optEmp.orElseGet(User::new);

            if (optEmp.isEmpty()) {
                employe.setEmail(employeEmail);
                employe.setNom("Trabelsi");
                employe.setPrenom("Ahmed");
                employe.setCin("EMP001");
                employe.setPhone("0655001122");
                employe.setAssuranceId("EMP_AHMED");
            }

            employe.setPasswordHash(passwordEncoder.encode(employePassword));
            employe.setRole("employe");
            employe.setVerified(true);
            userRepository.save(employe);

            System.out.println("==================================================");
            System.out.println("✅ COMPTE EMPLOYÉ PRÊT !");
            System.out.println("   Email: " + employeEmail);
            System.out.println("==================================================");
        } catch (Exception e) {
            System.err.println("Impossible de configurer le compte employé: " + e.getMessage());
        }
    }

    public Map<String, Object> setupAdminAccount() {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            Optional<User> opt = userRepository.findByEmail(adminEmail);
            User admin;
            
            if (opt.isPresent()) {
                admin = opt.get();
                result.put("action", "UPDATE");
            } else {
                admin = new User();
                admin.setEmail(adminEmail);
                admin.setNom("Ben Ali");
                admin.setPrenom("Sarra");
                admin.setCin("ADMIN001");
                admin.setPhone("0600000000");
                admin.setAssuranceId("ADMIN_SARRA");
                result.put("action", "CREATE");
            }
            
            admin.setPasswordHash(passwordEncoder.encode(adminPassword));
            admin.setRole("admin");
            admin.setVerified(true);
            userRepository.save(admin);
            
            result.put("success", true);
            result.put("email", adminEmail);
            result.put("role", admin.getRole());
            result.put("verified", admin.isVerified());
            result.put("user_id", admin.getId());
        } catch (Exception e) {
            result.put("success", false);
            result.put("error", e.getMessage());
            result.put("error_class", e.getClass().getName());
        }
        return result;
    }

    // ─── Vérification assurance ───
    public Map<String, Object> verifyInsurance(String assuranceId, String cin) {
        Optional<Assurance> opt = assuranceRepository.findByAssuranceId(assuranceId);

        if (opt.isEmpty()) {
            return Map.of(
                "verified", false,
                "message", "Aucun assuré trouvé avec l'ID « " + assuranceId + " ». Vérifiez votre ID d'assurance."
            );
        }

        Assurance assurance = opt.get();

        if (!assurance.getCin().equals(cin)) {
            return Map.of(
                "verified", false,
                "message", "Le numéro d'identité ne correspond pas à cet ID d'assurance."
            );
        }

        // Check if account already exists
        if (userRepository.existsByAssuranceId(assuranceId)) {
            return Map.of(
                "verified", false,
                "message", "Un compte existe déjà pour cet ID d'assurance. Veuillez vous connecter."
            );
        }

        // Return insurance data for pre-fill
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("assuranceId", assurance.getAssuranceId());
        data.put("nom", assurance.getNom());
        data.put("prenom", assurance.getPrenom());
        data.put("cin", assurance.getCin());
        data.put("phone", assurance.getPhone() != null ? assurance.getPhone() : "");
        data.put("vehicleBrand", assurance.getVehicleBrand() != null ? assurance.getVehicleBrand() : "");
        data.put("vehicleModel", assurance.getVehicleModel() != null ? assurance.getVehicleModel() : "");
        data.put("vehiclePlate", assurance.getVehiclePlate() != null ? assurance.getVehiclePlate() : "");
        data.put("compagnie", assurance.getCompagnie() != null ? assurance.getCompagnie() : "");

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("verified", true);
        result.put("message", "Coordonnées validées");
        result.put("data", data);
        return result;
    }

    // Map pour stocker les inscriptions en attente (en mémoire)
    private final Map<String, PendingRegistration> pendingRegistrations = new java.util.concurrent.ConcurrentHashMap<>();

    private static class PendingRegistration {
        RegisterRequest request;
        String code;
        LocalDateTime expiresAt;

        public PendingRegistration(RegisterRequest request, String code, LocalDateTime expiresAt) {
            this.request = request;
            this.code = code;
            this.expiresAt = expiresAt;
        }
    }

    // ─── Inscription ───
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            return AuthResponse.builder()
                    .success(false)
                    .message("Cette adresse email est déjà utilisée.")
                    .build();
        }

        if (userRepository.existsByAssuranceId(req.getAssuranceId())) {
            return AuthResponse.builder()
                    .success(false)
                    .message("Un compte existe déjà pour cet ID d'assurance.")
                    .build();
        }

        // Verify insurance exists
        Optional<Assurance> assuranceOpt = assuranceRepository.findByAssuranceIdAndCin(
                req.getAssuranceId(), req.getCin());
        if (assuranceOpt.isEmpty()) {
            return AuthResponse.builder()
                    .success(false)
                    .message("L'ID d'assurance ou le CIN est invalide.")
                    .build();
        }

        // Generate 6-digit PIN
        String code = generatePinCode();
        PendingRegistration pending = new PendingRegistration(req, code, LocalDateTime.now().plusMinutes(15));
        pendingRegistrations.put(req.getEmail(), pending);

        // Send Email
        emailService.sendVerificationEmail(req.getEmail(), code);

        Map<String, Object> fakeUserMap = new LinkedHashMap<>();
        fakeUserMap.put("assurance_id", req.getAssuranceId());
        fakeUserMap.put("nom", req.getNom());
        fakeUserMap.put("prenom", req.getPrenom());
        fakeUserMap.put("cin", req.getCin());
        fakeUserMap.put("phone", req.getPhone() != null ? req.getPhone() : "");
        fakeUserMap.put("email", req.getEmail());
        fakeUserMap.put("vehicle_brand", req.getVehicleBrand() != null ? req.getVehicleBrand() : "");
        fakeUserMap.put("vehicle_model", req.getVehicleModel() != null ? req.getVehicleModel() : "");
        fakeUserMap.put("vehicle_plate", req.getVehiclePlate() != null ? req.getVehiclePlate() : "");
        fakeUserMap.put("insurance_number", req.getAssuranceId());
        
        if (assuranceOpt.isPresent()) {
            Assurance assurance = assuranceOpt.get();
            fakeUserMap.put("compagnie", assurance.getCompagnie() != null ? assurance.getCompagnie() : "");
            fakeUserMap.put("dateExpiration", assurance.getDateExpiration() != null ? assurance.getDateExpiration().toString() : "");
        }

        // Don't send token yet, wait for verification
        return AuthResponse.builder()
                .success(true)
                .message("Un code de vérification a été envoyé à votre email. Le compte sera créé après vérification.")
                .user(fakeUserMap)
                .build();
    }

    // ─── Connexion ───
    public AuthResponse login(String email, String password) {
        Optional<User> opt = userRepository.findByEmail(email);
        if (opt.isEmpty()) {
            return AuthResponse.builder()
                    .success(false)
                    .message("Email ou mot de passe incorrect")
                    .build();
        }

        User user = opt.get();
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            return AuthResponse.builder()
                    .success(false)
                    .message("Email ou mot de passe incorrect")
                    .build();
        }

        if (!user.isVerified()) {
            return AuthResponse.builder()
                    .success(false)
                    .message("not_verified") // Code spécial pour le frontend
                    .build();
        }

        String token = jwtUtil.generateToken(user.getEmail(), user.getId());

        return AuthResponse.builder()
                .success(true)
                .message("Connexion réussie")
                .token(token)
                .user(userToMap(user))
                .build();
    }

    // ─── Vérification Email ───
    public AuthResponse verifyEmail(String email, String code) {
        PendingRegistration pending = pendingRegistrations.get(email);
        if (pending != null) {
            if (!pending.code.equals(code)) {
                return AuthResponse.builder().success(false).message("Code PIN incorrect.").build();
            }
            if (pending.expiresAt.isBefore(LocalDateTime.now())) {
                return AuthResponse.builder().success(false).message("Le code a expiré. Veuillez en demander un nouveau.").build();
            }

            RegisterRequest req = pending.request;
            User user = User.builder()
                    .email(req.getEmail())
                    .passwordHash(passwordEncoder.encode(req.getPassword()))
                    .nom(req.getNom())
                    .prenom(req.getPrenom())
                    .cin(req.getCin())
                    .phone(req.getPhone())
                    .vehicleBrand(req.getVehicleBrand())
                    .vehicleModel(req.getVehicleModel())
                    .vehiclePlate(req.getVehiclePlate())
                    .assuranceId(req.getAssuranceId())
                    .role("client")
                    .isVerified(true)
                    .build();

            user = userRepository.save(user);
            pendingRegistrations.remove(email);

            String token = jwtUtil.generateToken(user.getEmail(), user.getId());

            return AuthResponse.builder()
                    .success(true)
                    .message("Compte créé et vérifié avec succès.")
                    .token(token)
                    .user(userToMap(user))
                    .build();
        }

        return AuthResponse.builder()
                .success(false)
                .message("Session de vérification expirée ou introuvable. Veuillez vous inscrire à nouveau.")
                .build();
    }

    public Map<String, Object> resendVerificationCode(String email) {
        PendingRegistration pending = pendingRegistrations.get(email);
        if (pending != null) {
            String code = generatePinCode();
            pending.code = code;
            pending.expiresAt = LocalDateTime.now().plusMinutes(15);
            emailService.sendVerificationEmail(email, code);
            return Map.of("success", true, "message", "Nouveau code de vérification envoyé.");
        }

        return Map.of("success", false, "message", "Session de vérification expirée. Veuillez vous inscrire à nouveau.");
    }

    private String generatePinCode() {
        SecureRandom random = new SecureRandom();
        int num = random.nextInt(1000000);
        return String.format("%06d", num);
    }

    // ─── Mot de passe oublié ───
    public Map<String, Object> forgotPassword(String email) {
        Optional<User> opt = userRepository.findByEmail(email);
        if (opt.isEmpty()) {
            return Map.of(
                "success", false,
                "message", "Aucun compte trouvé avec cette adresse email."
            );
        }

        // Generate a reset token (6-char alphanumeric for simplicity)
        String resetToken = UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        PasswordResetToken prt = PasswordResetToken.builder()
                .token(resetToken)
                .user(opt.get())
                .expiresAt(LocalDateTime.now().plusHours(1))
                .used(false)
                .build();
        resetTokenRepository.save(prt);

        // In production, send email here. For now, return token in response (dev mode)
        emailService.sendPasswordResetEmail(email, resetToken);
        
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("message", "Le lien de réinitialisation a été envoyé à votre adresse email.");
        result.put("resetToken", resetToken); // keep in dev mode just in case
        return result;
    }

    // ─── Reset password ───
    public Map<String, Object> resetPassword(String token, String newPassword) {
        Optional<PasswordResetToken> opt = resetTokenRepository.findByTokenAndUsedFalse(token);
        if (opt.isEmpty()) {
            return Map.of("success", false, "message", "Token invalide ou déjà utilisé.");
        }

        PasswordResetToken prt = opt.get();
        if (prt.getExpiresAt().isBefore(LocalDateTime.now())) {
            return Map.of("success", false, "message", "Le token a expiré.");
        }

        User user = prt.getUser();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        prt.setUsed(true);
        resetTokenRepository.save(prt);

        return Map.of("success", true, "message", "Mot de passe réinitialisé avec succès.");
    }

    // ─── Get current user ───
    public Map<String, Object> getUserProfile(User user) {
        return userToMap(user);
    }

    // ─── Update profile ───
    public Map<String, Object> updateProfile(User user, Map<String, String> updates) {
        if (updates.containsKey("phone")) user.setPhone(updates.get("phone"));
        if (updates.containsKey("email")) user.setEmail(updates.get("email"));
        if (updates.containsKey("vehicleBrand")) user.setVehicleBrand(updates.get("vehicleBrand"));
        if (updates.containsKey("vehicleModel")) user.setVehicleModel(updates.get("vehicleModel"));
        if (updates.containsKey("vehiclePlate")) user.setVehiclePlate(updates.get("vehiclePlate"));

        userRepository.save(user);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("message", "Profil mis à jour");
        result.put("user", userToMap(user));
        return result;
    }

    // ─── Helper ───
    private Map<String, Object> userToMap(User user) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("assurance_id", user.getAssuranceId());
        map.put("nom", user.getNom());
        map.put("prenom", user.getPrenom());
        map.put("cin", user.getCin());
        map.put("phone", user.getPhone() != null ? user.getPhone() : "");
        map.put("email", user.getEmail());
        map.put("vehicle_brand", user.getVehicleBrand() != null ? user.getVehicleBrand() : "");
        map.put("vehicle_model", user.getVehicleModel() != null ? user.getVehicleModel() : "");
        map.put("vehicle_plate", user.getVehiclePlate() != null ? user.getVehiclePlate() : "");
        map.put("insurance_number", user.getAssuranceId());
        map.put("role", user.getRole() != null ? user.getRole() : "client");

        if (user.getAssuranceId() != null) {
            assuranceRepository.findByAssuranceId(user.getAssuranceId()).ifPresent(assurance -> {
                map.put("compagnie", assurance.getCompagnie() != null ? assurance.getCompagnie() : "");
                map.put("dateExpiration", assurance.getDateExpiration() != null ? assurance.getDateExpiration().toString() : "");
            });
        }
        return map;
    }
}
