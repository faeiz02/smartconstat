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
                .build();

        // Handle circonstances list → comma-separated string
        if (data.get("circonstances") instanceof List<?> list) {
            constat.setCirconstances(String.join(",", list.stream()
                    .map(Object::toString).toList()));
        }

        constat = constatRepository.save(constat);

        return Map.of(
                "success", true,
                "data", Map.of("id", constat.getId())
        );
    }

    public List<Map<String, Object>> getUserConstats(User user) {
        List<Constat> constats = constatRepository.findByUserOrderByCreatedAtDesc(user);
        List<Map<String, Object>> result = new ArrayList<>();

        for (Constat c : constats) {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", c.getId());
            map.put("lieu", c.getLieu());
            map.put("dateTime", c.getDateTime() != null ? c.getDateTime().toString() : null);
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
            // Convert comma-separated circonstances back to list
            if (c.getCirconstances() != null && !c.getCirconstances().isEmpty()) {
                map.put("circonstances", Arrays.asList(c.getCirconstances().split(",")));
            } else {
                map.put("circonstances", List.of());
            }
            result.add(map);
        }

        return result;
    }
}
