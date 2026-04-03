-- ─── Données de test : Assurances ───
-- Ces entrées simulent les données qui étaient dans Firestore

INSERT INTO assurances (assurance_id, nom, prenom, cin, phone, vehicle_brand, vehicle_model, vehicle_plate, compagnie, date_expiration) VALUES
('ASS001', 'Dupont', 'Jean', 'AB123456', '0612345678', 'Renault', 'Clio', '1234-AB-01', 'AXA', '2027-12-31'),
('ASS002', 'Martin', 'Marie', 'CD789012', '0698765432', 'Peugeot', '308', '5678-CD-02', 'Allianz', '2027-06-30'),
('ASS003', 'Bernard', 'Pierre', 'EF345678', '0611223344', 'Toyota', 'Yaris', '9012-EF-03', 'MAIF', '2027-09-15'),
('ASS004', 'Petit', 'Sophie', 'GH901234', '0655667788', 'Volkswagen', 'Golf', '3456-GH-04', 'Groupama', '2026-12-31'),
('ASS005', 'Robert', 'Lucas', 'IJ567890', '0644556677', 'BMW', 'Serie 3', '7890-IJ-05', 'MMA', '2027-03-31');
