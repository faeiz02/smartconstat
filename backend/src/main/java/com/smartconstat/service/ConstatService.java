package com.smartconstat.service;

import com.smartconstat.model.ClientNotification;
import com.smartconstat.model.Constat;
import com.smartconstat.model.ConstatAction;
import com.smartconstat.model.Facture;
import com.smartconstat.model.User;
import com.smartconstat.repository.AssuranceRepository;
import com.smartconstat.repository.ClientNotificationRepository;
import com.smartconstat.repository.ConstatActionRepository;
import com.smartconstat.repository.ConstatRepository;
import com.smartconstat.repository.FactureRepository;
import com.smartconstat.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Transactional
public class ConstatService {

    private final ConstatRepository constatRepository;
    private final ConstatActionRepository actionRepository;
    private final UserRepository userRepository;
    private final AssuranceRepository assuranceRepository;
    private final FactureRepository factureRepository;
    private final ClientNotificationRepository notificationRepository;

    public static final double FACTURE_EXPERTISE_THRESHOLD = 500.0;

    public static final List<String> STATUTS = List.of(
            "Non examiné",
            "En cours d'exécution",
            "Documents manquants",
            "En expertise",
            "Traité",
            "Rejeté",
            "Archivé"
    );

    public Map<String, Object> createConstat(User user, Map<String, Object> data) {
        Constat constat = Constat.builder()
                .user(user)
                .lieu((String) data.get("lieu"))
                .dateTime(data.get("dateTime") != null
                        ? LocalDateTime.parse((String) data.get("dateTime"))
                        : LocalDateTime.now())
                .statut("Non examiné")
                .assureurA((String) data.get("assureurA"))
                .contratA((String) data.get("contratA"))
                .nomA((String) data.get("nomA"))
                .prenomA((String) data.get("prenomA"))
                .adresseA((String) data.get("adresseA"))
                .vehiculeMarqueA((String) data.get("vehiculeMarqueA"))
                .vehiculeModeleA((String) data.get("vehiculeModeleA"))
                .immatriculationA((String) data.get("immatriculationA"))
                .paysA((String) data.get("paysA"))
                .assureurB((String) data.get("assureurB"))
                .contratB((String) data.get("contratB"))
                .nomB((String) data.get("nomB"))
                .prenomB((String) data.get("prenomB"))
                .adresseB((String) data.get("adresseB"))
                .vehiculeMarqueB((String) data.get("vehiculeMarqueB"))
                .vehiculeModeleB((String) data.get("vehiculeModeleB"))
                .immatriculationB((String) data.get("immatriculationB"))
                .paysB((String) data.get("paysB"))
                .pointChocInitial((String) data.get("pointChocInitial"))
                .degatsApparentsA((String) data.get("degatsApparentsA"))
                .degatsApparentsB((String) data.get("degatsApparentsB"))
                .autresDegats((String) data.get("autresDegats"))
                .observations((String) data.get("observations"))
                .sensSuiviA((String) data.get("sensSuiviA"))
                .sensSuiviB((String) data.get("sensSuiviB"))
                .temoins((String) data.get("temoins"))
                .blesses(Boolean.TRUE.equals(data.get("blesses")))
                .degatsMaterielsAutres(Boolean.TRUE.equals(data.get("degatsMaterielsAutres")))
                .interventionPolice(Boolean.TRUE.equals(data.get("interventionPolice")))
                .priorite(data.get("priorite") != null ? (String) data.get("priorite") : "Normale")
                .dateLimite(data.get("dateLimite") != null
                        ? parseDateTime((String) data.get("dateLimite"))
                        : LocalDateTime.now().plusDays(3))
                .build();

        // Handle circonstances list → comma-separated string
        if (data.get("circonstances") instanceof List<?> list) {
            constat.setCirconstances(String.join(",", list.stream()
                    .map(Object::toString).toList()));
        }

        constat = constatRepository.save(constat);
        addAction(constat, user, "CREATION", null, constat.getStatut(), "Constat créé");

        return Map.of(
                "success", true,
                "data", Map.of("accidentId", constat.getId().toString())
        );
    }

    public void saveConstatFiles(Long id, String croquisPath, String signatureAPath, String signatureBPath, String photosPaths) {
        Optional<Constat> opt = constatRepository.findById(id);
        if (opt.isPresent()) {
            Constat c = opt.get();
            if (croquisPath != null) c.setCroquisPath(croquisPath);
            if (signatureAPath != null) c.setSignatureAPath(signatureAPath);
            if (signatureBPath != null) c.setSignatureBPath(signatureBPath);
            if (photosPaths != null) c.setPhotosPaths(photosPaths);
            constatRepository.save(c);
        }
    }

    public boolean constatExists(Long id) {
        return constatRepository.existsById(id);
    }

    public boolean canAccessConstat(Long id, User user) {
        if (user == null) return false;
        Optional<Constat> opt = constatRepository.findById(id);
        if (opt.isEmpty()) return false;

        String role = user.getRole() != null ? user.getRole() : "client";
        if ("admin".equals(role) || "employe".equals(role)) return true;

        Constat constat = opt.get();
        return constat.getUser() != null && constat.getUser().getId().equals(user.getId());
    }

    public List<Map<String, Object>> getUserConstats(User user) {
        List<Constat> constats = constatRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        return constatsToMapList(constats);
    }

    /** Dashboard: get all constats (optionally filtered by statut) */
    public List<Map<String, Object>> getAllConstats(String statut) {
        List<Constat> constats;
        if (statut != null && !statut.isBlank()) {
            constats = constatRepository.findByStatutOrderByCreatedAtDesc(statut);
        } else {
            constats = constatRepository.findAllByOrderByCreatedAtDesc();
        }
        return constatsToMapList(constats);
    }

    /** Dashboard employe: get constats visible to this employee */
    public List<Map<String, Object>> getConstatsForEmploye(User employe) {
        List<Constat> constats = constatRepository.findConstatsForEmploye(employe);
        return constatsToMapList(constats);
    }

    /** Update the statut of a constat and assign to employee */
    public boolean updateConstatStatut(Long constatId, String newStatut, User employe) {
        return updateConstatStatut(constatId, newStatut, employe, null);
    }

    public boolean updateConstatStatut(Long constatId, String newStatut, User actor, String comment) {
        Optional<Constat> opt = constatRepository.findById(constatId);
        if (opt.isEmpty()) return false;

        Constat c = opt.get();
        String role = actor != null && actor.getRole() != null ? actor.getRole() : "client";
        if ("client".equals(role)) return false;

        if ("employe".equals(role)) {
            boolean assignedToCurrent = c.getTraitePar() != null && c.getTraitePar().getId().equals(actor.getId());
            boolean closingStatus = "Traité".equals(newStatut) || "Rejeté".equals(newStatut) || "Archivé".equals(newStatut);
            if (closingStatus && !assignedToCurrent) return false;
            if ("Non examiné".equals(newStatut) || "Archivé".equals(newStatut)) return false;
        }

        if (c.getTraitePar() != null && actor != null
                && !c.getTraitePar().getId().equals(actor.getId())
                && "En cours d'exécution".equals(c.getStatut())
                && !"admin".equals(role)) {
            return false;
        }

        if ("Rejeté".equals(newStatut) && (comment == null || comment.isBlank())) {
            return false;
        }

        String oldStatut = c.getStatut();
        c.setStatut(newStatut);

        boolean noFacturesYet = c.getNombreFactures() == null || c.getNombreFactures() == 0;
        if ("Trait\u00e9".equals(newStatut) && !"Trait\u00e9".equals(oldStatut) && noFacturesYet) {
            c.setFactureStatut("Factures demandees");
            c.setPriseEnChargeDecision("Constat traite. En attente des factures du client.");
            notifyClient(
                    c,
                    "Factures demandees",
                    "Votre constat #" + c.getId() + " est traite. Merci de fournir les factures de reparation dans le dossier.",
                    "FACTURES_DEMANDEES"
            );
        }

        if ("En cours d'exécution".equals(newStatut) && actor != null) {
            c.setTraitePar(actor);
            c.setTraiteParNom(fullName(actor));
        }
        if ("Rejeté".equals(newStatut)) {
            c.setMotifRejet(comment);
        }
        if ("Non examiné".equals(newStatut)) {
            c.setTraitePar(null);
            c.setTraiteParNom(null);
        }

        c = constatRepository.save(c);
        addAction(c, actor, "STATUT", oldStatut, newStatut, comment);
        return true;
    }

    /** Backward compatible version */
    public boolean updateConstatStatut(Long constatId, String newStatut) {
        return updateConstatStatut(constatId, newStatut, null);
    }

    public boolean assignConstat(Long constatId, Long employeId, User admin, String comment) {
        if (admin == null || !"admin".equals(admin.getRole())) return false;
        Optional<Constat> constatOpt = constatRepository.findById(constatId);
        Optional<User> employeOpt = userRepository.findById(employeId);
        if (constatOpt.isEmpty() || employeOpt.isEmpty()) return false;

        User employe = employeOpt.get();
        if (!"employe".equals(employe.getRole()) && !"admin".equals(employe.getRole())) return false;

        Constat constat = constatOpt.get();
        String previous = constat.getTraiteParNom();
        constat.setTraitePar(employe);
        constat.setTraiteParNom(fullName(employe));
        if ("Non examiné".equals(constat.getStatut())) {
            constat.setStatut("En cours d'exécution");
        }
        constat = constatRepository.save(constat);
        addAction(constat, admin, "AFFECTATION", previous, constat.getTraiteParNom(), comment);
        return true;
    }

    public boolean updateTracking(Long constatId, User actor, Map<String, Object> body) {
        if (actor == null || (!"admin".equals(actor.getRole()) && !"employe".equals(actor.getRole()))) return false;
        Optional<Constat> opt = constatRepository.findById(constatId);
        if (opt.isEmpty()) return false;

        Constat c = opt.get();
        if ("employe".equals(actor.getRole())) {
            boolean assignedToCurrent = c.getTraitePar() != null && c.getTraitePar().getId().equals(actor.getId());
            if (!assignedToCurrent) return false;
        }

        if (body.containsKey("priorite")) c.setPriorite(asString(body.get("priorite")));
        if (body.containsKey("dateLimite")) {
            String value = asString(body.get("dateLimite"));
            c.setDateLimite(value == null || value.isBlank() ? null : parseDateTime(value));
        }
        if (body.containsKey("noteInterne")) c.setNoteInterne(asString(body.get("noteInterne")));
        if (body.containsKey("documentsManquants")) c.setDocumentsManquants(asString(body.get("documentsManquants")));
        if (body.containsKey("commentaireDecision")) c.setCommentaireDecision(asString(body.get("commentaireDecision")));
        if (body.containsKey("responsabiliteEstimee")) c.setResponsabiliteEstimee(asString(body.get("responsabiliteEstimee")));
        if (body.containsKey("montantEstime")) {
            Object value = body.get("montantEstime");
            c.setMontantEstime(value instanceof Number number ? number.doubleValue() : null);
        }
        if (body.containsKey("escalade")) c.setEscalade(Boolean.TRUE.equals(body.get("escalade")));
        if (body.containsKey("escaladeRaison")) c.setEscaladeRaison(asString(body.get("escaladeRaison")));

        c = constatRepository.save(c);
        addAction(c, actor, "SUIVI", null, null, asString(body.get("comment")));
        return true;
    }

    public List<Map<String, Object>> getConstatHistory(Long constatId) {
        return actionRepository.findByConstatIdOrderByCreatedAtDesc(constatId)
                .stream()
                .map(this::actionToMap)
                .toList();
    }

    public Map<String, Object> getAdminNotifications() {
        List<Constat> constats = constatRepository.findAll();
        LocalDateTime now = LocalDateTime.now();
        long urgent = constats.stream().filter(c -> "Urgente".equals(c.getPriorite()) || c.isBlesses() || c.isInterventionPolice()).count();
        long blocked = constats.stream().filter(c -> "Documents manquants".equals(c.getStatut()) || c.isEscalade()).count();
        long overdue = constats.stream().filter(c -> c.getDateLimite() != null
                && c.getDateLimite().isBefore(now)
                && !List.of("Traité", "Rejeté", "Archivé").contains(c.getStatut())).count();
        long expiredContracts = assuranceRepository.findAll().stream()
                .filter(a -> a.getDateExpiration() != null && a.getDateExpiration().isBefore(LocalDate.now()))
                .count();
        long pendingInvoices = factureRepository.findAll().stream()
                .filter(f -> "À payer".equals(f.getStatut()))
                .count();

        return Map.of(
                "urgentConstats", urgent,
                "blockedConstats", blocked,
                "overdueConstats", overdue,
                "expiredContracts", expiredContracts,
                "pendingInvoices", pendingInvoices
        );
    }

    public List<Map<String, Object>> getEmployeePerformance() {
        List<User> staff = userRepository.findAll().stream()
                .filter(u -> "employe".equals(u.getRole()) || "admin".equals(u.getRole()))
                .toList();

        List<Map<String, Object>> result = new ArrayList<>();
        for (User user : staff) {
            long assigned = constatRepository.countByTraitePar(user);
            long treated = constatRepository.countByTraiteParAndStatut(user, "Traité");
            long rejected = constatRepository.countByTraiteParAndStatut(user, "Rejeté");
            long closed = treated + rejected;
            long rejectionRate = closed == 0 ? 0 : Math.round((rejected * 100.0) / closed);

            Map<String, Object> map = new LinkedHashMap<>();
            map.put("userId", user.getId());
            map.put("name", fullName(user));
            map.put("role", user.getRole());
            map.put("active", user.isActive());
            map.put("assigned", assigned);
            map.put("treated", treated);
            map.put("rejected", rejected);
            map.put("rejectionRate", rejectionRate);
            result.add(map);
        }
        return result;
    }

    private List<Map<String, Object>> constatsToMapList(List<Constat> constats) {
        List<Map<String, Object>> result = new ArrayList<>();

        for (Constat c : constats) {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", c.getId());
            map.put("accidentId", c.getId() != null ? c.getId().toString() : null);
            map.put("lieu", c.getLieu());
            map.put("dateTime", c.getDateTime() != null ? c.getDateTime().toString() : null);
            map.put("statut", c.getStatut());
            map.put("assureurA", c.getAssureurA());
            map.put("contratA", c.getContratA());
            map.put("nomA", c.getNomA());
            map.put("prenomA", c.getPrenomA());
            map.put("adresseA", c.getAdresseA());
            map.put("vehiculeMarqueA", c.getVehiculeMarqueA());
            map.put("vehiculeModeleA", c.getVehiculeModeleA());
            map.put("immatriculationA", c.getImmatriculationA());
            map.put("paysA", c.getPaysA());
            map.put("assureurB", c.getAssureurB());
            map.put("contratB", c.getContratB());
            map.put("nomB", c.getNomB());
            map.put("prenomB", c.getPrenomB());
            map.put("adresseB", c.getAdresseB());
            map.put("vehiculeMarqueB", c.getVehiculeMarqueB());
            map.put("vehiculeModeleB", c.getVehiculeModeleB());
            map.put("immatriculationB", c.getImmatriculationB());
            map.put("paysB", c.getPaysB());
            map.put("pointChocInitial", c.getPointChocInitial());
            map.put("degatsApparentsA", c.getDegatsApparentsA());
            map.put("degatsApparentsB", c.getDegatsApparentsB());
            map.put("autresDegats", c.getAutresDegats());
            map.put("observations", c.getObservations());
            map.put("sensSuiviA", c.getSensSuiviA());
            map.put("sensSuiviB", c.getSensSuiviB());
            map.put("temoins", c.getTemoins());
            map.put("blesses", c.isBlesses());
            map.put("degatsMaterielsAutres", c.isDegatsMaterielsAutres());
            map.put("interventionPolice", c.isInterventionPolice());
            map.put("croquisPath", c.getCroquisPath());
            map.put("signatureAPath", c.getSignatureAPath());
            map.put("signatureBPath", c.getSignatureBPath());
            map.put("photosPaths", c.getPhotosPaths());
            map.put("priorite", c.getPriorite());
            map.put("dateLimite", c.getDateLimite() != null ? c.getDateLimite().toString() : null);
            map.put("noteInterne", c.getNoteInterne());
            map.put("documentsManquants", c.getDocumentsManquants());
            map.put("motifRejet", c.getMotifRejet());
            map.put("commentaireDecision", c.getCommentaireDecision());
            map.put("responsabiliteEstimee", c.getResponsabiliteEstimee());
            map.put("montantEstime", c.getMontantEstime());
            map.put("factureStatut", c.getFactureStatut());
            map.put("montantFacturesTotal", c.getMontantFacturesTotal());
            map.put("nombreFactures", c.getNombreFactures());
            map.put("priseEnChargeDecision", c.getPriseEnChargeDecision());
            map.put("escalade", c.isEscalade());
            map.put("escaladeRaison", c.getEscaladeRaison());
            map.put("updatedAt", c.getUpdatedAt() != null ? c.getUpdatedAt().toString() : null);
            map.put("factures", c.getId() != null
                    ? factureRepository.findByConstatIdOrderByEcheanceDesc(c.getId()).stream().map(this::factureToMap).toList()
                    : List.of());
            // Convert comma-separated circonstances back to list
            if (c.getCirconstances() != null && !c.getCirconstances().isEmpty()) {
                map.put("circonstances", Arrays.asList(c.getCirconstances().split(",")));
            } else {
                map.put("circonstances", List.of());
            }
            // Add user info for dashboard
            if (c.getUser() != null) {
                map.put("userName", (c.getUser().getNom() != null ? c.getUser().getNom() : "") + " " + (c.getUser().getPrenom() != null ? c.getUser().getPrenom() : ""));
                map.put("userEmail", c.getUser().getEmail());
            }
            // Info employé qui traite
            map.put("traiteParNom", c.getTraiteParNom());
            map.put("traiteParId", c.getTraitePar() != null ? c.getTraitePar().getId() : null);
            result.add(map);
        }

        return result;
    }

    private void addAction(Constat constat, User actor, String actionType, String oldValue, String newValue, String comment) {
        actionRepository.save(ConstatAction.builder()
                .constat(constat)
                .actor(actor)
                .actorName(actor != null ? fullName(actor) : "Systeme")
                .actionType(actionType)
                .oldStatut(oldValue)
                .newStatut(newValue)
                .comment(comment)
                .build());
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

    private Map<String, Object> factureToMap(Facture facture) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", facture.getId());
        map.put("mois", facture.getMois());
        map.put("montant", facture.getMontant());
        map.put("echeance", facture.getEcheance() != null ? facture.getEcheance().toString() : null);
        map.put("statut", facture.getStatut());
        map.put("typeFacture", facture.getTypeFacture());
        map.put("photoUrl", facture.getPhotoUrl());
        map.put("decisionStatut", facture.getDecisionStatut());
        map.put("decisionCommentaire", facture.getDecisionCommentaire());
        map.put("decisionAt", facture.getDecisionAt() != null ? facture.getDecisionAt().toString() : null);
        return map;
    }

    private Map<String, Object> actionToMap(ConstatAction action) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", action.getId());
        map.put("actorName", action.getActorName());
        map.put("actorId", action.getActor() != null ? action.getActor().getId() : null);
        map.put("actionType", action.getActionType());
        map.put("oldStatut", action.getOldStatut());
        map.put("newStatut", action.getNewStatut());
        map.put("comment", action.getComment());
        map.put("createdAt", action.getCreatedAt() != null ? action.getCreatedAt().toString() : null);
        return map;
    }

    private String fullName(User user) {
        String nom = user.getNom() != null ? user.getNom() : "";
        String prenom = user.getPrenom() != null ? user.getPrenom() : "";
        String fullName = (nom + " " + prenom).trim();
        return fullName.isEmpty() ? user.getEmail() : fullName;
    }

    private String asString(Object value) {
        return value == null ? null : value.toString();
    }

    private LocalDateTime parseDateTime(String value) {
        return value.length() == 10 ? LocalDate.parse(value).atStartOfDay() : LocalDateTime.parse(value);
    }
}
