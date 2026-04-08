package com.smartconstat.service;

import com.smartconstat.model.*;
import com.smartconstat.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AppServicesService {

    private final FactureRepository factureRepository;
    private final EmergencyNumberRepository emergencyNumberRepository;
    private final AssistanceTypeRepository assistanceTypeRepository;
    private final DevisRequestRepository devisRequestRepository;
    private final HealthcareProfessionalRepository hpRepository;

    public List<Facture> getUserFactures(User user) {
        return factureRepository.findByUserOrderByEcheanceDesc(user);
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

    public DevisRequest createDevisRequest(User user, Map<String, Object> data) {
        String assuranceType = (String) data.getOrDefault("assuranceType", "Assurance Auto");
        DevisRequest req = DevisRequest.builder()
                .user(user)
                .assuranceType(assuranceType)
                .build();
        return devisRequestRepository.save(req);
    }
}
