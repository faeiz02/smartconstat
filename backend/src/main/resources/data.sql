-- ─── Données de test : Assurances ───
-- Ces entrées simulent les données qui étaient dans Firestore

INSERT INTO assurances (assurance_id, nom, prenom, cin, phone, vehicle_brand, vehicle_model, vehicle_plate, compagnie, date_expiration) VALUES
('ASS001', 'Dupont', 'Jean', 'AB123456', '0612345678', 'Renault', 'Clio', '1234-AB-01', 'AXA', '2027-12-31'),
('ASS002', 'Martin', 'Marie', 'CD789012', '0698765432', 'Peugeot', '308', '5678-CD-02', 'Allianz', '2027-06-30'),
('ASS003', 'Bernard', 'Pierre', 'EF345678', '0611223344', 'Toyota', 'Yaris', '9012-EF-03', 'MAIF', '2027-09-15'),
('ASS004', 'Petit', 'Sophie', 'GH901234', '0655667788', 'Volkswagen', 'Golf', '3456-GH-04', 'Groupama', '2026-12-31'),
('ASS005', 'Robert', 'Lucas', 'IJ567890', '0644556677', 'BMW', 'Serie 3', '7890-IJ-05', 'MMA', '2027-03-31');

-- Données de test : Assistance 24/7
INSERT INTO emergency_numbers (label, number, icon_str) VALUES
('Assistance dépannage', '31 31', 'Icons.car_repair_outlined'),
('Assistance médicale', '19 19', 'Icons.medical_services_outlined'),
('Assistance domicile', '31 32', 'Icons.home_repair_service_outlined');

INSERT INTO assistance_types (title, description, icon_str) VALUES
('Dépannage', 'Véhicule en panne', 'Icons.car_repair_outlined'),
('Médicale', 'Urgence santé', 'Icons.medical_services_outlined'),
('Domicile', 'Plombier, électricien', 'Icons.home_repair_service_outlined'),
('Juridique', 'Conseil juridique', 'Icons.gavel_outlined');

-- Données de test : Réseau de Soins
INSERT INTO healthcare_professionals (name, type, address, distance_str, phone, rating, review_count, bio) VALUES
('Clinique Les Jasmins', 'Clinique', 'Centre Urbain Nord, Tunis', '1.2 km', '71 123 456', 4.5, 128, 'Établissement moderne offrant une large gamme de spécialités médicales et chirurgicales avec des équipements de pointe.'),
('Dr. Mohamed Salah', 'Généraliste', 'Mutuelle Ville, Tunis', '2.5 km', '71 987 654', 4.8, 56, 'Médecin de famille dévoué, avec plus de 20 ans d\'expérience dans le suivi global des patients.'),
('Polyclinique CNSS', 'Clinique', 'Montplaisir, Tunis', '3.0 km', '71 111 222', 4.2, 340, 'Grande structure hospitalière au service des affiliés, couvrant les urgences et soins spécialisés.'),
('Dr. Leila Mansour', 'Dentiste', 'Lafayette, Tunis', '1.8 km', '71 333 444', 4.9, 89, 'Chirurgien-dentiste spécialisée en esthétique dentaire et implantologie.');

-- removed teleconsultation
