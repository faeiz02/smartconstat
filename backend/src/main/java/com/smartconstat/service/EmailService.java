package com.smartconstat.service;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender javaMailSender;

    @org.springframework.beans.factory.annotation.Value("${spring.mail.username}")
    private String senderEmail;

    @org.springframework.beans.factory.annotation.Value("${app.backend.url}")
    private String backendUrl;

    public void sendVerificationEmail(String toEmail, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(senderEmail);
        message.setTo(toEmail);
        message.setSubject("SmartConstat - Vérification de votre compte");
        message.setText("Bienvenue sur SmartConstat !\n\n" +
                "Votre code de vérification à 6 chiffres est : " + code + "\n\n" +
                "Ce code expire dans 15 minutes.\n" +
                "Si vous n'avez pas demandé cette vérification, vous pouvez ignorer cet email.");

        try {
            javaMailSender.send(message);
            System.out.println("=========================================");
            System.out.println(" EMAIL VÉRIFICATION ENVOYÉ À : " + toEmail);
            System.out.println(" CODE D'ACTIVATION     : " + code);
            System.out.println("=========================================");
        } catch (Exception e) {
            System.err.println("Erreur d'envoi de mail : " + e.getMessage());
            System.out.println("=========================================");
            System.out.println(" CODE D'ACTIVATION (Fallback) : " + code);
            System.out.println("=========================================");
        }
    }

    public void sendPasswordResetEmail(String toEmail, String resetToken) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(senderEmail);
        message.setTo(toEmail);
        message.setSubject("SmartConstat - Réinitialisation de mot de passe");
        
        String resetLink = backendUrl + "/api/auth/reset-password-page?token=" + resetToken;
        
        message.setText("Bonjour,\n\n" +
                "Vous avez demandé la réinitialisation de votre mot de passe.\n\n" +
                "Veuillez cliquer sur le lien ci-dessous pour créer un nouveau mot de passe :\n" +
                resetLink + "\n\n" +
                "Ce lien expire dans 1 heure.\n" +
                "Si vous n'avez pas demandé cette réinitialisation, vous pouvez ignorer cet email.");

        try {
            javaMailSender.send(message);
            System.out.println("=========================================");
            System.out.println(" EMAIL RESET ENVOYÉ À : " + toEmail);
            System.out.println(" LIEN DE RESET        : " + resetLink);
            System.out.println("=========================================");
        } catch (Exception e) {
            System.err.println("Erreur d'envoi de mail : " + e.getMessage());
            System.out.println("=========================================");
            System.out.println(" LIEN DE RESET (Fallback) : " + resetLink);
            System.out.println("=========================================");
        }
    }
}
