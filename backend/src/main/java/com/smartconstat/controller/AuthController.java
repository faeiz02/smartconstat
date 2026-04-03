package com.smartconstat.controller;

import com.smartconstat.dto.*;
import com.smartconstat.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest req) {
        AuthResponse response = authService.login(req.getEmail(), req.getPassword());
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest req) {
        AuthResponse response = authService.register(req);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PostMapping("/verify-insurance")
    public ResponseEntity<?> verifyInsurance(@Valid @RequestBody InsuranceVerifyRequest req) {
        Map<String, Object> result = authService.verifyInsurance(
                req.getAssuranceId(), req.getCin());
        boolean verified = (boolean) result.get("verified");
        if (verified) {
            return ResponseEntity.ok(result);
        }
        return ResponseEntity.badRequest().body(result);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ResetPasswordRequest req) {
        Map<String, Object> result = authService.forgotPassword(req.getEmail());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody NewPasswordRequest req) {
        Map<String, Object> result = authService.resetPassword(
                req.getToken(), req.getNewPassword());
        boolean success = (boolean) result.get("success");
        if (success) {
            return ResponseEntity.ok(result);
        }
        return ResponseEntity.badRequest().body(result);
    }
    @PostMapping("/verify-email")
    public ResponseEntity<?> verifyEmail(@RequestBody Map<String, String> req) {
        String email = req.get("email");
        String code = req.get("code");
        AuthResponse response = authService.verifyEmail(email, code);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PostMapping("/resend-code")
    public ResponseEntity<?> resendCode(@RequestBody Map<String, String> req) {
        String email = req.get("email");
        Map<String, Object> result = authService.resendVerificationCode(email);
        boolean success = (boolean) result.get("success");
        if (success) {
            return ResponseEntity.ok(result);
        }
        return ResponseEntity.badRequest().body(result);
    }

    @GetMapping("/reset-password-page")
    public ResponseEntity<String> resetPasswordPage(@RequestParam String token) {
        String html = "<!DOCTYPE html><html><head><meta charset=\"UTF-8\">"
            + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
            + "<title>Réinitialisation du mot de passe</title>"
            + "<style>"
            + "body{font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;background:linear-gradient(to bottom, #050D1F, #0F2B5B);color:#fff;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;} "
            + ".card{background:rgba(255,255,255,0.08);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:1px solid rgba(255,255,255,0.12);padding:2.5rem;border-radius:24px;box-shadow:0 4px 6px rgba(0,0,0,0.1);text-align:center;width:90%;max-width:400px;box-sizing:border-box;} "
            + "h2{color:#fff;margin-bottom:0.5rem;font-size:24px;} "
            + "p.subtext{color:rgba(255,255,255,0.6);font-size:14px;margin-bottom:2rem;} "
            + "input{width:100%;padding:14px;margin-bottom:1.2rem;border:none;border-radius:16px;box-sizing:border-box;font-size:15px;background:#fff;color:#333;box-shadow:0 4px 12px rgba(0,0,0,0.05);} "
            + "input:focus{outline:2px solid #F59E0B;} "
            + "button{background-color:#F59E0B;color:#fff;border:none;padding:14px;border-radius:16px;cursor:pointer;width:100%;font-size:16px;font-weight:bold;margin-top:0.5rem;box-shadow:0 4px 12px rgba(245,158,11,0.4);transition:transform 0.2s;} "
            + "button:hover{transform:translateY(-2px);background-color:#FBBF24;} "
            + ".error,.success{margin-bottom:1.5rem;font-weight:bold;padding:1rem;border-radius:12px;} "
            + ".error{background:rgba(239,68,68,0.2);color:#ef4444;border:1px solid rgba(239,68,68,0.4);} "
            + ".success{background:rgba(34,197,94,0.2);color:#22c55e;border:1px solid rgba(34,197,94,0.4);} "
            + "</style></head><body>"
            + "<div class=\"card\">"
            + "<h2>Nouveau Mot de Passe</h2>"
            + "<p class=\"subtext\">Veuillez entrer votre nouveau mot de passe ci-dessous.</p>"
            + "<div id=\"message\"></div>"
            + "<form id=\"resetForm\">"
            + "<input type=\"hidden\" id=\"token\" value=\"" + token + "\">"
            + "<input type=\"password\" id=\"newPassword\" placeholder=\"Nouveau mot de passe (min. 6 car.)\" required minlength=\"6\">"
            + "<input type=\"password\" id=\"confirmPassword\" placeholder=\"Confirmer le mot de passe\" required minlength=\"6\">"
            + "<button type=\"submit\" id=\"submitBtn\">RÉINITIALISER</button>"
            + "</form>"
            + "<script>"
            + "document.getElementById('resetForm').addEventListener('submit', function(e) {"
            + "  e.preventDefault();"
            + "  const btn = document.getElementById('submitBtn');"
            + "  btn.disabled = true; btn.innerText = 'EN COURS...';"
            + "  const token = document.getElementById('token').value;"
            + "  const p1 = document.getElementById('newPassword').value;"
            + "  const p2 = document.getElementById('confirmPassword').value;"
            + "  const msgDiv = document.getElementById('message');"
            + "  if(p1 !== p2) {"
            + "      msgDiv.innerHTML = '<div class=\"error\">Les mots de passe ne correspondent pas.</div>';"
            + "      btn.disabled = false; btn.innerText = 'RÉINITIALISER';"
            + "      return;"
            + "  }"
            + "  if(p1.length < 6) {"
            + "      msgDiv.innerHTML = '<div class=\"error\">Le mot de passe doit contenir au moins 6 caractères.</div>';"
            + "      btn.disabled = false; btn.innerText = 'RÉINITIALISER';"
            + "      return;"
            + "  }"
            + "  fetch('/api/auth/reset-password', {"
            + "    method: 'POST',"
            + "    headers: { 'Content-Type': 'application/json' },"
            + "    body: JSON.stringify({ token: token, newPassword: p1 })"
            + "  }).then(res => res.json()).then(data => {"
            + "    if(data.success) {"
            + "      msgDiv.innerHTML = '<div class=\"success\">Mot de passe réinitialisé avec succès !<br><br>Vous pouvez maintenant fermer cette page et retourner à l\\'application pour vous connecter.</div>';"
            + "      document.getElementById('resetForm').style.display = 'none';"
            + "      document.querySelector('.subtext').style.display = 'none';"
            + "    } else {"
            + "      msgDiv.innerHTML = '<div class=\"error\">' + (data.message || 'Le lien est invalide ou a expiré.') + '</div>';"
            + "      btn.disabled = false; btn.innerText = 'RÉINITIALISER';"
            + "    }"
            + "  }).catch(err => {"
            + "    msgDiv.innerHTML = '<div class=\"error\">Erreur de connexion serveur.</div>';"
            + "    btn.disabled = false; btn.innerText = 'RÉINITIALISER';"
            + "  });"
            + "});"
            + "</script>"
            + "</div></body></html>";
        return ResponseEntity.ok().header("Content-Type", "text/html").body(html);
    }
}
