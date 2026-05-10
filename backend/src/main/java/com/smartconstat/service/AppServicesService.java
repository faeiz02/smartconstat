package com.smartconstat.service;

import com.smartconstat.model.*;
import com.smartconstat.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class AppServicesService {

    private final FactureRepository factureRepository;
    private final ConstatRepository constatRepository;
    private final ClientNotificationRepository notificationRepository;
    private final EmergencyNumberRepository emergencyNumberRepository;
    private final AssistanceTypeRepository assistanceTypeRepository;
    private final HealthcareProfessionalRepository hpRepository;

    public List<Map<String, Object>> getUserFactures(User user) {
        return factureRepository.findByUserOrderByEcheanceDesc(user)
                .stream()
                .map(this::factureToMap)
                .toList();
    }

    public List<Map<String, Object>> getUserFacturesByType(User user, String typeFacture) {
        return factureRepository.findByUserAndTypeFactureOrderByEcheanceDesc(user, typeFacture)
                .stream()
                .map(this::factureToMap)
                .toList();
    }

    public boolean deleteFacture(Long factureId, User user) {
        Optional<Facture> opt = factureRepository.findById(factureId);
        if (opt.isPresent() && opt.get().getUser().getId().equals(user.getId())) {
            factureRepository.deleteById(factureId);
            return true;
        }
        return false;
    }

    public Facture createFacture(User user, String mois, Double montant, String echeance, String typeFacture) {
        return createFacture(user, mois, montant, echeance, typeFacture, null);
    }

    public Facture createFacture(User user, String mois, Double montant, String echeance, String typeFacture, Long constatId) {
        Constat constat = null;
        if (constatId != null) {
            Optional<Constat> opt = constatRepository.findById(constatId);
            if (opt.isEmpty() || opt.get().getUser() == null || !opt.get().getUser().getId().equals(user.getId())) {
                throw new IllegalArgumentException("Dossier constat non trouve ou non autorise");
            }
            constat = opt.get();
        }

        Facture facture = Facture.builder()
                .user(user)
                .constat(constat)
                .mois(mois)
                .montant(montant)
                .echeance(echeance != null ? LocalDate.parse(echeance) : null)
                .statut(constat != null ? "En attente" : "\u00c0 payer")
                .typeFacture(typeFacture != null ? typeFacture : "Autre")
                .decisionStatut(constat != null ? "En attente" : null)
                .build();
        facture = factureRepository.save(facture);
        if (constat != null) {
            evaluateDossierFactures(constat);
        }
        return facture;
    }

    public boolean saveFacturePhoto(Long factureId, String photoUrl, User user) {
        Optional<Facture> opt = factureRepository.findById(factureId);
        if (opt.isPresent()) {
            Facture facture = opt.get();
            if (facture.getUser().getId().equals(user.getId())) {
                facture.setPhotoUrl(photoUrl);
                factureRepository.save(facture);
                return true;
            }
        }
        return false;
    }

    public List<EmergencyNumber> getEmergencyNumbers() {
        return emergencyNumberRepository.findAll();
    }

    public List<AssistanceType> getAssistanceTypes() {
        return assistanceTypeRepository.findAll();
    }

    public List<HealthcareProfessional> getHealthcareProfessionals() {
        return hpRepository.findAll();
    }

    /** Admin: Get ALL factures with user info */
    public List<Map<String, Object>> getAllFactures() {
        List<Facture> factures = factureRepository.findAll();
        List<Map<String, Object>> result = new java.util.ArrayList<>();
        for (Facture f : factures) {
            Map<String, Object> map = factureToMap(f);
            if (f.getUser() != null) {
                map.put("userId", f.getUser().getId());
                map.put("userName", (f.getUser().getNom() != null ? f.getUser().getNom() : "") + " " + (f.getUser().getPrenom() != null ? f.getUser().getPrenom() : ""));
                map.put("userEmail", f.getUser().getEmail());
            }
            result.add(map);
        }
        return result;
    }

    private void evaluateDossierFactures(Constat constat) {
        List<Facture> factures = factureRepository.findByConstatId(constat.getId());
        double total = factures.stream()
                .map(Facture::getMontant)
                .filter(java.util.Objects::nonNull)
                .mapToDouble(Double::doubleValue)
                .sum();

        constat.setNombreFactures(factures.size());
        constat.setMontantFacturesTotal(total);

        boolean requiresExpert = total > ConstatService.FACTURE_EXPERTISE_THRESHOLD;
        String decisionStatut = requiresExpert ? "Expertise requise" : "Prise en charge directe";
        String decision = requiresExpert
                ? "Le total des factures depasse 500 TND. Une expertise est requise avant la prise en charge finale."
                : "Le total des factures est inferieur ou egal a 500 TND. La prise en charge peut etre traitee sans expertise.";

        constat.setFactureStatut(decisionStatut);
        constat.setPriseEnChargeDecision(decision);
        constat.setMontantEstime(total);

        if (requiresExpert) {
            constat.setStatut("En expertise");
            constat.setEscalade(true);
            constat.setEscaladeRaison("Total factures > 500 TND");
        }

        LocalDateTime now = LocalDateTime.now();
        for (Facture facture : factures) {
            facture.setStatut(decisionStatut);
            facture.setDecisionStatut(decisionStatut);
            facture.setDecisionCommentaire(decision);
            facture.setDecisionAt(now);
        }

        factureRepository.saveAll(factures);
        constatRepository.save(constat);
        notifyClient(
                constat,
                decisionStatut,
                requiresExpert
                        ? "Vos factures du constat #" + constat.getId() + " depassent 500 TND. Le dossier passe en expertise."
                        : "Vos factures du constat #" + constat.getId() + " sont inferieures ou egales a 500 TND. La prise en charge directe est lancee.",
                requiresExpert ? "EXPERTISE_REQUISE" : "PRISE_EN_CHARGE_DIRECTE"
        );
    }

    private void notifyClient(Constat constat, String title, String message, String type) {
        if (constat == null || constat.getUser() == null) return;
        notificationRepository.save(ClientNotification.builder()
                .user(constat.getUser())
                .constat(constat)
                .title(title)
                .message(message)
                .type(type)
                .build());
    }

    private Map<String, Object> factureToMap(Facture f) {
        Map<String, Object> map = new java.util.LinkedHashMap<>();
        map.put("id", f.getId());
        map.put("mois", f.getMois());
        map.put("montant", f.getMontant());
        map.put("echeance", f.getEcheance() != null ? f.getEcheance().toString() : null);
        map.put("statut", f.getStatut());
        map.put("typeFacture", f.getTypeFacture());
        map.put("photoUrl", f.getPhotoUrl());
        map.put("decisionStatut", f.getDecisionStatut());
        map.put("decisionCommentaire", f.getDecisionCommentaire());
        map.put("decisionAt", f.getDecisionAt() != null ? f.getDecisionAt().toString() : null);
        if (f.getConstat() != null) {
            map.put("constatId", f.getConstat().getId());
            map.put("dossierStatut", f.getConstat().getStatut());
            map.put("factureStatut", f.getConstat().getFactureStatut());
            map.put("montantFacturesTotal", f.getConstat().getMontantFacturesTotal());
            map.put("priseEnChargeDecision", f.getConstat().getPriseEnChargeDecision());
        }
        return map;
    }

    /** Admin: delete any facture */
    public boolean adminDeleteFacture(Long id) {
        if (factureRepository.existsById(id)) {
            factureRepository.deleteById(id);
            return true;
        }
        return false;
    }

    // ─── Healthcare CRUD ───
    public HealthcareProfessional createHealthcareProfessional(HealthcareProfessional hp) {
        return hpRepository.save(hp);
    }

    public HealthcareProfessional updateHealthcareProfessional(Long id, HealthcareProfessional updated) {
        Optional<HealthcareProfessional> opt = hpRepository.findById(id);
        if (opt.isEmpty()) return null;
        HealthcareProfessional hp = opt.get();
        hp.setName(updated.getName());
        hp.setType(updated.getType());
        hp.setAddress(updated.getAddress());
        hp.setDistanceStr(updated.getDistanceStr());
        hp.setPhone(updated.getPhone());
        hp.setRating(updated.getRating());
        hp.setReviewCount(updated.getReviewCount());
        hp.setBio(updated.getBio());
        return hpRepository.save(hp);
    }

    public boolean deleteHealthcareProfessional(Long id) {
        if (hpRepository.existsById(id)) { hpRepository.deleteById(id); return true; }
        return false;
    }

    // ─── Emergency Numbers CRUD ───
    public EmergencyNumber createEmergencyNumber(EmergencyNumber en) {
        return emergencyNumberRepository.save(en);
    }

    public EmergencyNumber updateEmergencyNumber(Long id, EmergencyNumber updated) {
        Optional<EmergencyNumber> opt = emergencyNumberRepository.findById(id);
        if (opt.isEmpty()) return null;
        EmergencyNumber en = opt.get();
        en.setLabel(updated.getLabel());
        en.setNumber(updated.getNumber());
        en.setIconStr(updated.getIconStr());
        return emergencyNumberRepository.save(en);
    }

    public boolean deleteEmergencyNumber(Long id) {
        if (emergencyNumberRepository.existsById(id)) { emergencyNumberRepository.deleteById(id); return true; }
        return false;
    }

    // ─── Assistance Types CRUD ───
    public AssistanceType createAssistanceType(AssistanceType at) {
        return assistanceTypeRepository.save(at);
    }

    public AssistanceType updateAssistanceType(Long id, AssistanceType updated) {
        Optional<AssistanceType> opt = assistanceTypeRepository.findById(id);
        if (opt.isEmpty()) return null;
        AssistanceType at = opt.get();
        at.setTitle(updated.getTitle());
        at.setDescription(updated.getDescription());
        at.setIconStr(updated.getIconStr());
        return assistanceTypeRepository.save(at);
    }

    public boolean deleteAssistanceType(Long id) {
        if (assistanceTypeRepository.existsById(id)) { assistanceTypeRepository.deleteById(id); return true; }
        return false;
    }
}
