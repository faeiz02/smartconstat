package com.smartconstat.service;

import com.smartconstat.model.*;
import com.smartconstat.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AppServicesService {

    private final FactureRepository factureRepository;
    private final EmergencyNumberRepository emergencyNumberRepository;
    private final AssistanceTypeRepository assistanceTypeRepository;
    private final HealthcareProfessionalRepository hpRepository;

    public List<Facture> getUserFactures(User user) {
        return factureRepository.findByUserOrderByEcheanceDesc(user);
    }

    public List<Facture> getUserFacturesByType(User user, String typeFacture) {
        return factureRepository.findByUserAndTypeFactureOrderByEcheanceDesc(user, typeFacture);
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
        Facture facture = Facture.builder()
                .user(user)
                .mois(mois)
                .montant(montant)
                .echeance(echeance != null ? LocalDate.parse(echeance) : null)
                .statut("À payer")
                .typeFacture(typeFacture != null ? typeFacture : "Autre")
                .build();
        return factureRepository.save(facture);
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
            Map<String, Object> map = new java.util.LinkedHashMap<>();
            map.put("id", f.getId());
            map.put("mois", f.getMois());
            map.put("montant", f.getMontant());
            map.put("echeance", f.getEcheance() != null ? f.getEcheance().toString() : null);
            map.put("statut", f.getStatut());
            map.put("typeFacture", f.getTypeFacture());
            map.put("photoUrl", f.getPhotoUrl());
            if (f.getUser() != null) {
                map.put("userId", f.getUser().getId());
                map.put("userName", (f.getUser().getNom() != null ? f.getUser().getNom() : "") + " " + (f.getUser().getPrenom() != null ? f.getUser().getPrenom() : ""));
                map.put("userEmail", f.getUser().getEmail());
            }
            result.add(map);
        }
        return result;
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
