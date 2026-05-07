-- Création de la base de données
CREATE DATABASE IF NOT EXISTS smartconstat_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smartconstat_db;

-- 1. Table Assurances (référentiel de la compagnie d'assurance)
CREATE TABLE IF NOT EXISTS assurances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    assurance_id VARCHAR(255) NOT NULL UNIQUE,
    nom VARCHAR(255),
    prenom VARCHAR(255),
    cin VARCHAR(255),
    phone VARCHAR(255),
    vehicle_brand VARCHAR(255),
    vehicle_model VARCHAR(255),
    vehicle_plate VARCHAR(255),
    compagnie VARCHAR(255),
    date_expiration DATE
);

-- 2. Table Users (les utilisateurs inscrits via l'app)
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nom VARCHAR(255),
    prenom VARCHAR(255),
    cin VARCHAR(255),
    phone VARCHAR(255),
    vehicle_brand VARCHAR(255),
    vehicle_model VARCHAR(255),
    vehicle_plate VARCHAR(255),
    assurance_id VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'client',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Table Constats (historique des accidents)
CREATE TABLE IF NOT EXISTS constats (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    lieu VARCHAR(255),
    date_time TIMESTAMP,
    
    -- Conducteur A (L'utilisateur)
    assureur_a VARCHAR(255),
    contrat_a VARCHAR(255),
    nom_a VARCHAR(255),
    prenom_a VARCHAR(255),
    adresse_a VARCHAR(255),
    vehicule_marque_a VARCHAR(255),
    vehicule_modele_a VARCHAR(255),
    immatriculation_a VARCHAR(255),
    pays_a VARCHAR(255),
    sens_suivi_a VARCHAR(255),
    
    -- Conducteur B (Adverse)
    assureur_b VARCHAR(255),
    contrat_b VARCHAR(255),
    nom_b VARCHAR(255),
    prenom_b VARCHAR(255),
    adresse_b VARCHAR(255),
    vehicule_marque_b VARCHAR(255),
    vehicule_modele_b VARCHAR(255),
    immatriculation_b VARCHAR(255),
    pays_b VARCHAR(255),
    sens_suivi_b VARCHAR(255),
    
    -- Détails
    temoins TEXT,
    blesses BOOLEAN DEFAULT FALSE,
    degats_materiels_autres BOOLEAN DEFAULT FALSE,
    intervention_police BOOLEAN DEFAULT FALSE,
    circonstances TEXT,
    point_choc_initial VARCHAR(255),
    degats_apparents_a VARCHAR(255),
    degats_apparents_b VARCHAR(255),
    autres_degats TEXT,
    observations TEXT,
    croquis_path VARCHAR(255),
    signature_a_path VARCHAR(255),
    signature_b_path VARCHAR(255),
    photos_paths TEXT,
    statut VARCHAR(255) DEFAULT 'Non examiné',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_user_constat FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Table Tokens (pour la réinitialisation de mot de passe)
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    token VARCHAR(255) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT fk_user_token FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- OPTIONNEL: Injection des assurances fictives de test (à commenter en vrai environnement de production)
INSERT INTO assurances (assurance_id, nom, prenom, cin, phone, vehicle_brand, vehicle_model, vehicle_plate, compagnie, date_expiration) VALUES
('ASS001', 'Dupont', 'Jean', 'AB123456', '0612345678', 'Renault', 'Clio', '1234-AB-01', 'AXA', '2027-12-31'),
('ASS002', 'Martin', 'Marie', 'CD789012', '0698765432', 'Peugeot', '308', '5678-CD-02', 'Allianz', '2027-06-30'),
('ASS003', 'Bernard', 'Pierre', 'EF345678', '0611223344', 'Toyota', 'Yaris', '9012-EF-03', 'MAIF', '2027-09-15'),
('ASS004', 'Petit', 'Sophie', 'GH901234', '0655667788', 'Volkswagen', 'Golf', '3456-GH-04', 'Groupama', '2026-12-31'),
('ASS005', 'Robert', 'Lucas', 'IJ567890', '0644556677', 'BMW', 'Serie 3', '7890-IJ-05', 'MMA', '2027-03-31');

-- Compte admin par défaut (mot de passe: admin123 - bcrypt hash)
-- IMPORTANT: Le mot de passe est hashé avec BCrypt. Pour le changer, générez un nouveau hash.
INSERT INTO users (email, password_hash, nom, prenom, cin, phone, assurance_id, role, is_verified) VALUES
('sarra@smartconstat.tn', '$2a$10$hSwMMa9lqT4k4kfX7IPASu/TkiWoSOQuwGPK636miW.wbaS.W1v.m', 'Ben Ali', 'Sarra', 'ADMIN001', '0600000000', 'ADMIN_SARRA', 'admin', TRUE)
ON DUPLICATE KEY UPDATE role = 'admin';

-- 5. Table Factures
CREATE TABLE IF NOT EXISTS factures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    mois VARCHAR(255),
    montant DOUBLE,
    echeance DATE,
    statut VARCHAR(255),
    type_facture VARCHAR(255) DEFAULT 'Autre',
    CONSTRAINT fk_user_facture FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Migration: ajouter les colonnes si tables existantes
-- ALTER TABLE constats ADD COLUMN IF NOT EXISTS statut VARCHAR(255) DEFAULT 'Non examiné';
-- ALTER TABLE factures ADD COLUMN IF NOT EXISTS type_facture VARCHAR(255) DEFAULT 'Autre';

-- 6. Table DevisRequests
CREATE TABLE IF NOT EXISTS devis_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    assurance_type VARCHAR(255),
    statut VARCHAR(255) DEFAULT 'En attente',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_devis FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 7. Table Assistance Numbers (24/7)
CREATE TABLE IF NOT EXISTS emergency_numbers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    label VARCHAR(255),
    number VARCHAR(255),
    icon_str VARCHAR(255)
);

-- 8. Table Assistance Types 
CREATE TABLE IF NOT EXISTS assistance_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    description VARCHAR(255),
    icon_str VARCHAR(255)
);

-- 9. Table Healthcare Professionals (Réseau de soins)
CREATE TABLE IF NOT EXISTS healthcare_professionals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    type VARCHAR(255),
    address VARCHAR(255),
    distance_str VARCHAR(255),
    phone VARCHAR(255),
    rating DOUBLE,
    review_count INT,
    bio TEXT
);

-- 10. Table Avis (Avis et évaluations dynamiques)
CREATE TABLE IF NOT EXISTS avis (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rating DOUBLE NOT NULL,
    comment VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id BIGINT NOT NULL,
    professional_id BIGINT NOT NULL,
    CONSTRAINT fk_avis_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_avis_professional FOREIGN KEY (professional_id) REFERENCES healthcare_professionals(id) ON DELETE CASCADE
);

-- removed teleconsultation

-- Injection de données de test pour les Services
INSERT INTO emergency_numbers (label, number, icon_str) VALUES
('Assistance dépannage', '31 31', 'Icons.car_repair_outlined'),
('Assistance médicale', '19 19', 'Icons.medical_services_outlined'),
('Assistance domicile', '31 32', 'Icons.home_repair_service_outlined');

INSERT INTO assistance_types (title, description, icon_str) VALUES
('Dépannage', 'Véhicule en panne', 'Icons.car_repair_outlined'),
('Médicale', 'Urgence santé', 'Icons.medical_services_outlined'),
('Domicile', 'Plombier, électricien', 'Icons.home_repair_service_outlined'),
('Juridique', 'Conseil juridique', 'Icons.gavel_outlined');

INSERT INTO healthcare_professionals (name, type, address, distance_str, phone, rating, review_count, bio) VALUES
('Clinique Les Jasmins', 'Clinique', 'Centre Urbain Nord, Tunis', '1.2 km', '71 123 456', 4.5, 128, 'Établissement moderne offrant une large gamme de spécialités médicales et chirurgicales avec des équipements de pointe.'),
('Dr. Mohamed Salah', 'Généraliste', 'Mutuelle Ville, Tunis', '2.5 km', '71 987 654', 4.8, 56, 'Médecin de famille dévoué, avec plus de 20 ans d\'expérience dans le suivi global des patients.'),
('Polyclinique CNSS', 'Clinique', 'Montplaisir, Tunis', '3.0 km', '71 111 222', 4.2, 340, 'Grande structure hospitalière au service des affiliés, couvrant les urgences et soins spécialisés.'),
('Dr. Leila Mansour', 'Dentiste', 'Lafayette, Tunis', '1.8 km', '71 333 444', 4.9, 89, 'Chirurgien-dentiste spécialisée en esthétique dentaire et implantologie.');

-- Fake users to write reviews (if users are completely wiped, else it will fail foreign key. Just in case, if users table is populated by something else)
-- Assuming users exist when testing from app

-- Test Avis (Requires user_id=1 to exist, so we will not inject manual avis here unless we inject users, but let's assume the user will create an account)
-- removed teleconsultation
