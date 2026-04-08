package com.smartconstat.service;

import com.smartconstat.dto.AvisDto;
import com.smartconstat.dto.AvisRequestDto;
import com.smartconstat.model.Avis;
import com.smartconstat.model.HealthcareProfessional;
import com.smartconstat.model.User;
import com.smartconstat.repository.AvisRepository;
import com.smartconstat.repository.HealthcareProfessionalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AvisService {

    private final AvisRepository avisRepository;
    private final HealthcareProfessionalRepository professionalRepository;

    private User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (!(principal instanceof User)) {
            throw new RuntimeException("Utilisateur non authentifié");
        }
        return (User) principal;
    }

    public List<AvisDto> getAvisForProfessional(Long professionalId) {
        return avisRepository.findByHealthcareProfessionalIdOrderByCreatedAtDesc(professionalId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public AvisDto addAvis(AvisRequestDto request) {
        User user = getCurrentUser();

        HealthcareProfessional professional = professionalRepository.findById(request.getProfessionalId())
                .orElseThrow(() -> new RuntimeException("Professionnel de santé non trouvé"));

        // Vérifier si l'utilisateur a déjà laissé un avis pour ce professionnel
        Optional<Avis> existingAvis = avisRepository.findByUserIdAndHealthcareProfessionalId(user.getId(), professional.getId());
        if (existingAvis.isPresent()) {
            throw new RuntimeException("ALREADY_REVIEWED");
        }

        Avis avis = Avis.builder()
                .rating(request.getRating())
                .comment(request.getComment())
                .user(user)
                .healthcareProfessional(professional)
                .build();

        Avis savedAvis = avisRepository.save(avis);
        recalculateRating(professional);
        return toDto(savedAvis);
    }

    @Transactional
    public AvisDto updateAvis(Long avisId, AvisRequestDto request) {
        User user = getCurrentUser();

        Avis avis = avisRepository.findById(avisId)
                .orElseThrow(() -> new RuntimeException("Avis non trouvé"));

        if (!avis.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Vous ne pouvez modifier que votre propre avis");
        }

        avis.setRating(request.getRating());
        avis.setComment(request.getComment());
        Avis savedAvis = avisRepository.save(avis);

        recalculateRating(avis.getHealthcareProfessional());
        return toDto(savedAvis);
    }

    @Transactional
    public void deleteAvis(Long avisId) {
        User user = getCurrentUser();

        Avis avis = avisRepository.findById(avisId)
                .orElseThrow(() -> new RuntimeException("Avis non trouvé"));

        if (!avis.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Vous ne pouvez supprimer que votre propre avis");
        }

        HealthcareProfessional professional = avis.getHealthcareProfessional();
        avisRepository.delete(avis);
        recalculateRating(professional);
    }

    private void recalculateRating(HealthcareProfessional professional) {
        List<Avis> allAvis = avisRepository.findByHealthcareProfessionalIdOrderByCreatedAtDesc(professional.getId());
        double avg = allAvis.stream().mapToDouble(Avis::getRating).average().orElse(0.0);
        avg = Math.round(avg * 10.0) / 10.0;
        professional.setRating(avg);
        professional.setReviewCount(allAvis.size());
        professionalRepository.save(professional);
    }

    private AvisDto toDto(Avis avis) {
        String userName = "Utilisateur";
        Long userId = null;
        try {
            User u = avis.getUser();
            if (u != null) {
                userId = u.getId();
                String prenom = u.getPrenom() != null ? u.getPrenom() : "";
                String nom = u.getNom() != null ? u.getNom() : "";
                userName = (prenom + " " + nom).trim();
                if (userName.isEmpty()) userName = "Utilisateur";
            }
        } catch (Exception e) {
            // fallback
        }
        return AvisDto.builder()
                .id(avis.getId())
                .rating(avis.getRating())
                .comment(avis.getComment())
                .createdAt(avis.getCreatedAt())
                .userName(userName)
                .userId(userId)
                .professionalId(avis.getHealthcareProfessional().getId())
                .build();
    }
}
