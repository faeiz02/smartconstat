
ALTER TABLE factures ADD COLUMN IF NOT EXISTS constat_id BIGINT NULL;
ALTER TABLE factures ADD COLUMN IF NOT EXISTS decision_statut VARCHAR(255) NULL;
ALTER TABLE factures ADD COLUMN IF NOT EXISTS decision_commentaire TEXT NULL;
ALTER TABLE factures ADD COLUMN IF NOT EXISTS decision_at DATETIME(6) NULL;

CREATE TABLE IF NOT EXISTS client_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    constat_id BIGINT NULL,
    title VARCHAR(255),
    message TEXT,
    type VARCHAR(255),
    read_flag BIT DEFAULT 0,
    created_at DATETIME(6) NOT NULL,
    CONSTRAINT fk_client_notification_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_client_notification_constat FOREIGN KEY (constat_id) REFERENCES constats(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS insurance_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    type VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    price VARCHAR(255),
    details_json TEXT,
    status VARCHAR(255) NOT NULL DEFAULT 'EN_ATTENTE',
    decision_comment TEXT,
    processed_by_id BIGINT NULL,
    processed_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NULL,
    CONSTRAINT fk_insurance_request_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_insurance_request_processed_by FOREIGN KEY (processed_by_id) REFERENCES users(id) ON DELETE SET NULL
);
