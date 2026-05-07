package com.smartconstat.service;

import com.smartconstat.model.Constat;
import com.smartconstat.model.User;
import com.smartconstat.repository.ConstatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ConstatService {

    private final ConstatRepository constatRepository;

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
                .build();

        // Handle circonstances list → comma-separated string
        if (data.get("circonstances") instanceof List<?> list) {
            constat.setCirconstances(String.join(",", list.stream()
                    .map(Object::toString).toList()));
        }

        constat = constatRepository.save(constat);

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

    public List<Map<String, Object>> getUserConstats(User user) {
        List<Constat> constats = constatRepository.findByUserOrderByCreatedAtDesc(user);
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
        Optional<Constat> opt = constatRepository.findById(constatId);
        if (opt.isPresent()) {
            Constat c = opt.get();

            // Si un autre employé traite déjà ce constat, bloquer
            if (c.getTraitePar() != null && employe != null
                    && !c.getTraitePar().getId().equals(employe.getId())
                    && "En cours d'exécution".equals(c.getStatut())) {
                return false; // Déjà pris par un autre
            }

            c.setStatut(newStatut);

            // Assigner l'employé quand il commence le traitement
            if ("En cours d'exécution".equals(newStatut) && employe != null) {
                c.setTraitePar(employe);
                c.setTraiteParNom((employe.getNom() != null ? employe.getNom() : "") + " " + (employe.getPrenom() != null ? employe.getPrenom() : ""));
            }

            // Si traité ou rejeté, garder la trace mais libérer pour la visibilité
            if ("Traité".equals(newStatut) || "Rejeté".equals(newStatut)) {
                // Garder traiteParNom pour l'historique
            }

            // Si remis à "Non examiné", désassigner
            if ("Non examiné".equals(newStatut)) {
                c.setTraitePar(null);
                c.setTraiteParNom(null);
            }

            constatRepository.save(c);
            return true;
        }
        return false;
    }

    /** Backward compatible version */
    public boolean updateConstatStatut(Long constatId, String newStatut) {
        return updateConstatStatut(constatId, newStatut, null);
    }

    private List<Map<String, Object>> constatsToMapList(List<Constat> constats) {
        List<Map<String, Object>> result = new ArrayList<>();

        for (Constat c : constats) {
            Map<String, Object> map = new LinkedHashMap<>();
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
}
