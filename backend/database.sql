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
